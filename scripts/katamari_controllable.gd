@icon("res://KatamariObject.svg")
extends Node3D
#region Variables
#region Size
## Sets the size of the katamari, in meters.
@export_range(0.01, 0, 0.001, "or_greater", "hide_slider", "suffix:m") var Size:float = 1
var MinimumSize:float = Size
## Sets how much size objects give when rolled up. 
##
## 1 gives the full amount of size, 0 gives none.
@export_range(0, 1) var GrowthMultiplier:float = 1
#endregion
#region Physics
@export_group("Physics")
## Sets the katamari's speed relative to a size of 1m. This also affects the max speed.
@export_range(0, 0, 0.01, "or_greater", "hide_slider", "suffix:m/s²/m") var Speed:float = 1
## Sets how much the katamari's acceleration/top speed is multiplied.
@export var InclineSpeedMultiplier:Curve
## Determines if movement is currently enabled.
## Should usually be TRUE unless control of the katamari is lost (e.g. getting slammed into, quick turning, etc.)
var MovementEnabled:bool = true
var CameraMovementEnabled:bool = true
#endregion
#region Camera
@export_group("Camera")
## The camera's scale, relative to a size of 1m.
var CameraScale: float = 1
## Sets the camera's vertical shift, relative to the camera scale.
@export var CameraShift:float = 0
## Sets the camera's horizontal rotation in radians.
##
## This setting is extensively used for movement, and should only be modified in the editor (to change the initial rotation of the katamari when spawned in).
@export_range(-180, 180, 0.001, "radians_as_degrees") var CameraRotation:float = 0
## Sets the camera's vertical tilt in radians.
##
## Ideal range should be between -pi/2 rad and pi/2 rad (-180deg to 180deg)
@export_range(-90, 90, 0.001, "radians_as_degrees") var CameraTilt:float = 0
## An array of camera ranges and their respective camera scales/tilts.
##
## Bound determines the minimum size (in meters) for the size range.
## Scale determines the camera scale relative to the World3D (NOT the katamari!).
## Tilt determines the camera's tilt in radians.
## Shift determines the camera's vertical shift, relative to the World3D.
## Attributes, if available, determines the camera attributes file used by the camera when reaching the size area.
@export var CameraZones:Array[Dictionary] = [{Bound = 0, Scale = 1.5, Tilt = -15, Shift = .25, Attributes = load("res://misc/attr_test_00.tres")}]
## The bounds of the current camera zone.
## Automatically set when changing CurrentZone.
var CurrentZoneBounds:Vector2
## The index of the current camera zone.
var CurrentZone:int = 0
## The largest camera zone reached so far in a level.
var HighestZone := CurrentZone
## The amount of camera smoothing.
var CameraSmoothing:float = 0.85
#endregion
#region Input
## The input vector for the left stick.
var LeftStick:Vector2 = Vector2(0, 0)
## The input vector for the right stick.
var RightStick:Vector2 = Vector2(0, 0)
## The center point of both sticks.
var StickMidpoint:Vector2 = LeftStick.lerp(RightStick, 0.5)
## The angle of the line between both sticks, in radians.
var StickAngle:float = ((RightStick + Vector2(4,0))-LeftStick).angle()
## The amount of charge for the Dash.
var DashCharge:float = 0:
	set(newCharge):
		DashCharge = clampf(newCharge, -10, 100)
	get:
		return DashCharge
## The current dash direction.
var DashDir:int = 0:
	set (newDir):
		DashDir = signi(newDir)
	get:
		return DashDir
## Can the katamari dash?
@export var CanDash:bool = true
## Can the katamari quick turn?
@export var CanQuickTurn:bool = true
#endregion
#region Visual
@export_file("*.obj") var CoreModel:String = "res://models/core/core_generic.obj"
@export_file("*.png") var CoreTexture:String = "res://textures/core/core_test.png"
#endregion
#endregion

func _ready():
	loadCore(CoreTexture, CoreModel)
	changeCamArea(0, true)
	%KatamariCameraPivot.transform = Transform3D.IDENTITY.translated($KatamariBody.position * 0.2 * $"..".scale).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt)

func _process(delta):
	$SubViewport.size = get_viewport().size
	
	# Update camera angles
	CameraRotation -= StickAngle * 2.5 * delta
	
	# Transform camera
	%KatamariCamera.transform = Transform3D.IDENTITY.translated_local(Vector3(0, CameraShift, 2)).scaled(Vector3(CameraScale, CameraScale, CameraScale) * 0.2 * $"..".scale)
	%KatamariCameraPivot.transform = Transform3D.IDENTITY.translated(position * $"..".scale).translated_local($KatamariBody.position * 0.2 * $"..".scale).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt).interpolate_with(%KatamariCameraPivot.transform, CameraSmoothing)
	

	# Discharge / recharge dash
	if DashCharge < 0:
		DashCharge += 15 * delta
	elif DashCharge < 25:
		DashCharge = clamp(DashCharge - (delta * 20) * int(MovementEnabled), 0, 100)
	elif DashCharge < 100 and not is_equal_approx(DashCharge, 100):
		if MovementEnabled:
			MovementEnabled = false
			$KatamariDashAudio.stream = preload("res://sounds/game/dash_charge.mp3")
			$KatamariDashAudio.play()
		DashCharge += delta * 25
	if DashCharge <= 0 or not CanDash: DashDir = 0
	if CanDash and (MovementEnabled or DashCharge >= 25) and DashCharge >= 0 and ((Input.is_action_just_pressed("LS Dash Down") and DashDir < 1) or (Input.is_action_just_pressed("LS Dash Up") and DashDir > -1)):
		DashCharge += 4.5
		if Input.is_action_just_pressed("LS Dash Down"): DashDir = 1
		if Input.is_action_just_pressed("LS Dash Up"): DashDir = -1
	
	%KatamariDashEfPivot.scale = Vector3.ONE * Size * 1.15
	%KatamariDashEfPivot.rotation.y = %KatamariCameraPivot.rotation.y
	%KatamariDashEfPivot.rotation.x -= (4*PI) * delta
	%KatamariDashEfPivot/KatamariDashEfA.material_override.albedo_color = %KatamariDashEfPivot/KatamariDashEfA.material_override.albedo_color.lerp(Color(1, 1.2, 2, 1) * ((clampf(DashCharge-25, 0, 30) / 30)), 0.2)
	%KatamariDashEfPivot/KatamariDashEfB.material_override.albedo_color = %KatamariDashEfPivot/KatamariDashEfB.material_override.albedo_color.lerp(Color(1, 1.2, 2, 1) * ((clampf(DashCharge-55, 0, 30) / 30)), 0.2)
	
	# Update debug info
	$Debug/PanelL/StickL.set_position(Vector2(25, 25) + (25 * LeftStick))
	$Debug/PanelR/StickR.set_position(Vector2(25, 25) + (25 * RightStick))
	$Debug/StickM.set_position(Vector2(95, 45) + (25 * StickMidpoint))
	$Debug/Line2D.points = [Vector2(50, 50) + (25 * LeftStick), Vector2(150, 50) + (25 * RightStick)]
	$Debug/Label.rotation = StickAngle + (PI/2)
	$Debug/Label2.text = "a: %frad (%fdeg)" % [StickAngle, rad_to_deg(StickAngle)]
	$Debug/Label3.text = "x:%f\ny:%f\nz:%f\nVx:%f\nVy:%f\nVz:%f\nVr:%f" % [$KatamariBody.position.x, $KatamariBody.position.y, $KatamariBody.position.z, $KatamariBody.linear_velocity.x, $KatamariBody.linear_velocity.y, $KatamariBody.linear_velocity.z, ($KatamariBody.linear_velocity*Vector3(1,0,1)).length()]
	$Debug/Label4.text = "size:%dm%02dcm%01dmm\ndamp:%f" % [floori(Size), floori(Size * 100) % 100, floori(Size * 1000) % 10, $KatamariBody.linear_damp]
	$Debug/ProgressBar.value = DashCharge

func _physics_process(delta):
	# Handle movement inputs
	LeftStick = Input.get_vector("LS Left", "LS Right", "LS Up", "LS Down", 0.5)
	RightStick = Input.get_vector("RS Left", "RS Right", "RS Up", "RS Down", 0.5)
	StickMidpoint = (LeftStick + Vector2.LEFT).lerp(RightStick + Vector2.RIGHT, 0.5) * int(MovementEnabled)
	if StickMidpoint.length() <= 0.501: StickMidpoint = Vector2.ZERO
	StickAngle = ((RightStick + Vector2(4,0))-LeftStick).angle() * int(CameraMovementEnabled)
	
	# DEBUG: Adjust size
	if Input.is_action_pressed("DEBUG Bigger"): Size += delta
	if Input.is_action_pressed("DEBUG Smaller"): Size = maxf(Size - delta, 0.05)
	
	# Adjust physics settings
	$KatamariBody.gravity_scale = $"..".scale.y
	$KatamariBody/KatamariMeshPivot/KatamariMesh.scale = Vector3.ONE * Size * 1.15
	$KatamariBody/KatamariBaseCollision.scale = Vector3.ONE * Size
	$KatamariBody.center_of_mass = Vector3(0, -Size, 0)
	
	# Rotate katamari model (including objects and collision when that's implemented)
	var zRot:float = ($KatamariBody.linear_velocity.x * -8.1 / $"..".scale.x * delta) / Size
	var xRot:float = ($KatamariBody.linear_velocity.z * 8.1 / $"..".scale.z * delta) / Size
	$KatamariBody/KatamariMeshPivot.rotate_z(zRot)
	$KatamariBody/KatamariMeshPivot.rotate_x(xRot)
	
	# Rotate object collision
	for collider:Node3D in $KatamariBody.get_children():
		if collider is CollisionShape3D and collider.name != "KatamariBaseCollision":
			#collider.rotate_z(zRot)
			#collider.rotate_x(zRot)
			collider.transform = collider.transform.rotated(Vector3(0,0,1), zRot).rotated(Vector3(1,0,0), xRot)
	
	# Determine floor collision (old method)
	#var floorCollision:KinematicCollision3D = $KatamariBody.move_and_collide(Vector3.DOWN * 0.1, true)
	#var floorAngle:Vector3 = Vector3.UP
	#if floorCollision: floorAngle = floorCollision.get_normal()
	
	# Determine floor collision (new method)
	var floorCollision:KinematicCollision3D = $KatamariBody.move_and_collide(Vector3.DOWN * 0.1, true)
	var floorAngle:Vector3 = Vector3.UP
	if floorCollision: 
		floorAngle = floorCollision.get_normal(0)
		for col in floorCollision.get_collision_count():
			if floorCollision.get_angle(col) < PI/2:
				floorAngle = floorAngle.slerp(floorCollision.get_normal(col), 0.5)
	
	# Calculate movement vector (old method)
	var tempMovement:Vector2 = StickMidpoint.rotated(CameraRotation * -1)
	var finalMovement:Vector2 = tempMovement * Vector2($"..".scale.x, $"..".scale.z) * sqrt(Size) * Speed + ((tempMovement * Vector2(InclineSpeedMultiplier.sample((floorAngle.x * signf(tempMovement.x * -1)/2) + 0.5), InclineSpeedMultiplier.sample((floorAngle.z * signf(tempMovement.y * -1)/2) + 0.5)) - tempMovement) / pow(Speed, 1.0/3) * pow($KatamariBody.gravity_scale, 3))
	
	# Create movement force
	$KatamariBody.constant_force = Vector3(finalMovement.x, 0, finalMovement.y)
	
	# Create dash movement/force
	if CanDash:
		if DashCharge < 100 and DashCharge >= 25 and not is_equal_approx(DashCharge, 100):
			var zRotDash:float = (24 / $"..".scale.x * delta * sin(%KatamariCamera.global_rotation.y))
			var xRotDash:float = (-24 / $"..".scale.z * delta * cos(%KatamariCamera.global_rotation.y))
			$KatamariBody/KatamariMeshPivot.rotate_z(zRotDash)
			$KatamariBody/KatamariMeshPivot.rotate_x(xRotDash)
			
			# Rotate object collision
			for collider:Node3D in $KatamariBody.get_children():
				if collider is CollisionShape3D and collider.name != "KatamariBaseCollision":
					#collider.rotate_z(zRot)
					#collider.rotate_x(zRot)
					collider.transform = collider.transform.rotated(Vector3(0,0,1), zRotDash).rotated(Vector3(1,0,0), xRotDash)
		elif DashCharge > 99:
			$KatamariDashAudio.stop()
			$KatamariDashAudio.stream = preload("res://sounds/game/dash_release.mp3")
			$KatamariDashAudio.play()
			$KatamariBody.apply_central_impulse(Vector3(
				(Speed * -400 / $"..".scale.x * delta * sin(%KatamariCamera.global_rotation.y)) * Size,
				0,
				(Speed * -400 / $"..".scale.z * delta * cos(%KatamariCamera.global_rotation.y)) * Size
			))
			DashCharge = -10
			MovementEnabled = true
	
	# Detect size/camera area changes
	if Size < CurrentZoneBounds.x and CurrentZone > 0:
		changeCamArea(CurrentZone - 1) # Decrease camera area
	elif Size > CurrentZoneBounds.y:
		changeCamArea(CurrentZone + 1) # Decrease camera area
	
	# Detect quick turn
	if Input.is_action_just_pressed("Quick Turn Left") and Input.is_action_just_pressed("Quick Turn Right") and CanQuickTurn:
		doQuickTurn()

## Changes the current camera zone to CameraZones[index].
func changeCamArea(index:int, skipAnimation:bool = false):
	if index > CameraZones.size(): push_error("Camera zone index out of bounds")
	CurrentZone = index
	if CurrentZone > HighestZone: 
		HighestZone = CurrentZone
		if not skipAnimation: 
			%KatamariCamera/KatamariCameraZoom.play("CameraZoom")
	var nextBound := 1.79769e308
	if CameraZones.size() - 1 > CurrentZone: nextBound = CameraZones[CurrentZone+1].Bound
	CurrentZoneBounds = Vector2(CameraZones[CurrentZone].Bound, nextBound)
	print(CurrentZoneBounds.y)
	if CameraZones[CurrentZone].Attributes: 
		%KatamariCamera.attributes = CameraZones[CurrentZone].Attributes
	if skipAnimation:
		CameraScale = CameraZones[CurrentZone].Scale
		CameraTilt = deg_to_rad(CameraZones[CurrentZone].Tilt)
		CameraShift = CameraZones[CurrentZone].Shift
	else:
		var CameraTween = get_tree().create_tween()
		CameraTween.parallel().tween_property(self, "CameraScale", CameraZones[CurrentZone].Scale, 1)
		CameraTween.parallel().tween_property(self, "CameraTilt", deg_to_rad(CameraZones[CurrentZone].Tilt), 1)
		CameraTween.parallel().tween_property(self, "CameraShift", CameraZones[CurrentZone].Shift, 1)

func doQuickTurn():
	if MovementEnabled:
		MovementEnabled = false
		CameraMovementEnabled = false
		# put the quick turn code here
		var QTTiltTween = get_tree().create_tween()
		var QTRotTween = get_tree().create_tween()
		CameraSmoothing = 0.1
		$KatamariQTAudio.stream = preload("res://sounds/game/quick_turn.mp3")
		$KatamariQTAudio.play()
		QTRotTween.tween_property(self, "CameraRotation", CameraRotation + PI, 0.4).set_trans(Tween.TRANS_LINEAR)
		QTTiltTween.tween_property(self, "CameraTilt", ((-16 * PI) / 32), 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		QTTiltTween.tween_property(self, "CameraTilt", deg_to_rad(CameraZones[CurrentZone].Tilt), 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(0.4).timeout
		CameraSmoothing = 0.85
		MovementEnabled = true
		CameraMovementEnabled = true

func loadCore(texture:String = "res://textures/core/core_test.png", model:String = "res://models/core/core_generic.obj"):
	$KatamariBody/KatamariMeshPivot/KatamariMesh.mesh = load(model)
	$KatamariBody/KatamariMeshPivot/KatamariMesh.material_override.albedo_texture = load(texture)
