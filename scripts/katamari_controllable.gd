@icon("res://KatamariObject.svg")
extends Node3D
#region Variables
#region Size and Position
## Sets the size of the katamari, in meters.
@export_range(0.01, 0, 0.001, "or_greater", "hide_slider", "suffix:m") var Size:float = 1
var MinimumSize:float = Size
@export_range(0, 0, 1, "or_greater", "hide_slider", "suffix:pts.") var Score:int = 0
@onready var ScoringList:Dictionary = StageLoader.currentStage.modes.get(StageLoader.currentMode).get("goal_type_points", {}).get("point_objects", {})
## Sets how much size objects give when rolled up. 
##
## 1 gives the full amount of size, 0 gives none.
@export_range(0, 1) var GrowthMultiplier:float = 1
## Sets which sound set is used by this katamari.
@export var SoundSize:String = "M"
## Sets the spawn points this katamari can choose.
@export var SpawnPoints:Array = [Vector4.ZERO]

var ObjectQueue:Array[StringName] = []
#endregion
#region Physics
@export_group("Physics")
## Sets the katamari's speed relative to a size of 1m. This also affects the max speed.
@export_range(0, 0, 0.01, "or_greater", "hide_slider", "suffix:m/s²/m") var Speed:float = 5
## Sets how much the katamari's acceleration/top speed is multiplied.
@export var InclineSpeedMultiplier:Curve
## Sets the height at which a Royal Warp is triggered.
@export var RoyalWarpHeight:float = -10
## Determines if movement is currently enabled.
## Should usually be TRUE unless control of the katamari is lost (e.g. getting slammed into, quick turning, etc.)
var MovementEnabled:bool = true
var CameraMovementEnabled:bool = true
var Climbing:bool = false
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
## DOF determines the depth-of-field distance, in meters (relative to World3D). 0 disables Depth Of Field.
@export var CameraZones:Array = [{Bound = 0, Scale = 1.5, Tilt = -15, Shift = .25, DOF = 10}]
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
## The amount of fatigue for the Dash.
@onready var DashFatigue:float = 0:
	set(newFatigue):
		DashFatigue = clampf(newFatigue, 0, 100)
		if DashFatigue == 0: 
			Fatigued = false
			SpeedMultiplier = 1.3
			$KatamariBody.linear_damp = 1.5
		if DashFatigue == 100: 
			Fatigued = true
			SpeedMultiplier = 1
			$KatamariBody.linear_damp = 1.1
	get:
		return DashFatigue
## Is the player currently fatigued?
var Fatigued:bool = false
## Speed multiplier
var SpeedMultiplier:float = 1.3
var RoyalWarping:bool = false
## Can the katamari dash?
@export var CanDash:bool = true
## Can the katamari quick turn?
@export var CanQuickTurn:bool = true
#endregion
#region Visual
@export_file("*.obj") var CoreModel:String = "res://assets/models/core/core_generic.obj"
@export_file("*.png") var CoreTexture:String = "res://assets/textures/core/core_test.png"
#endregion

@export var Music:String = ""
@export var Pausable:bool = false

const RollSounds = {
	"XS": [preload("uid://d3gp43smimgy4"), preload("uid://ti521pkbxfs"), preload("uid://0litba7qydpt")],
	"S": [preload("uid://b5xq50lmixdve"), preload("uid://bmu3gyrkst2yn"), preload("uid://gjptanm2fkl8")],
	"M": [preload("uid://bi6nqj7yh7pq1"), preload("uid://dawg6qbhvr0ti"), preload("uid://cdeo3pysw4lim")],
	"L": [preload("uid://buvsaumcdq1oj"), preload("uid://c2m77sxy8mx83"), preload("uid://d1ecf2413mwnr")],
	"XL": [preload("uid://ckvrecid6eqe"), preload("uid://dq0jwr8i4pylr"), preload("uid://be5k6f8s4cq3k")],
	"C": [preload("uid://c8jvswahn2u5i"), preload("uid://c4oso3eov6mep"), preload("uid://xdxvj8epddip")]
}

# [0] - floor bounce, [1] - wall hit, [2] wall crumble
const BumpSounds = {
	"XS": [preload("uid://3djag7lgql2s"), preload("uid://cwqocvfyv8e2t"), preload("uid://ss0bpy7jir2u")],
	"S": [preload("uid://3djag7lgql2s"), preload("uid://bsd3iyu482wvs"), preload("uid://bkq6xqm1small")],
	"M": [preload("uid://c73vie5kjqqfq"), preload("uid://bphuyxjxr4eev"), preload("uid://cnx1fj5tj3m10")],
	"L": [preload("uid://f2xjjtjerdgh"), preload("uid://c3vmx0gs45dhc"), preload("uid://dv3v42siufu2m")],
	"XL": [preload("uid://f2xjjtjerdgh"), preload("uid://tyhho1aot677"), preload("uid://b5awtwif2uav")],
	"C": [null, null, null]
}
#endregion

func _ready():
	loadCore(CoreTexture, CoreModel)
	changeCamArea(0, true)
	%KatamariCameraPivot.transform = Transform3D.IDENTITY.translated($KatamariBody.position * $"..".scale).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt)
	respawn(true)
	
	# Now let's init the dialogue
	var mode:Dictionary = StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {})
	CanDash = mode.get("katamari", {}).get("can_dash", true) and mode.get("katamari", {}).get("can_dialogue_move", true)
	CanQuickTurn = mode.get("katamari", {}).get("can_turn", true) and mode.get("katamari", {}).get("can_dialogue_move", true)
	CameraMovementEnabled = mode.get("katamari", {}).get("can_dialogue_move", true)
	MovementEnabled = mode.get("katamari", {}).get("can_dialogue_move", true)
	if not StageLoader.restarted:
		DialogueBox.queue_dialog_string(GKGlobal.get_localized_string(mode.get("start_dialogue", {})))
	else:
		DialogueBox.queue_dialog_string(GKGlobal.get_localized_string(mode.get("retry_dialogue", {})))
	
	var music_array = GKGlobal.get_music(Music)
	$GameMusic.stream = music_array[0]
	## TODO: add music title gui element
	DialogueBox.speak_queue()
	await DialogueBox.queue_finished
	$GameMusic.play()
	MovementEnabled = true
	CameraMovementEnabled = true
	CanDash = mode.get("katamari", {}).get("can_dash", true)
	CanQuickTurn = mode.get("katamari", {}).get("can_turn", true)
	Pausable = true
	if $SizeMeter/OffsetBase.position.x == -500:
		$SizeMeter/SizeAnimation.play("Appear_Fast")
	if has_node("Timer"):
		$Timer.enabled = true
		await $Timer.timeout
		_end_stage()

func _end_stage():
	Pausable = false
	var mode:Dictionary = StageLoader.currentStage.get("modes", {}).get(StageLoader.currentMode, {})
	MovementEnabled = false
	CameraMovementEnabled = false
	CanDash = false
	CanQuickTurn = false
	$KatamariBody.process_mode = Node.PROCESS_MODE_DISABLED
	var won:bool = $SizeMeter.goal_reached(Size, Score)
	if has_node("Timer"): $Timer.play_gong(won)
	$GameMusic.stop()
	if won:
		DialogueBox.queue_dialog_string(GKGlobal.get_localized_string(mode.get("win_dialogue", {})), DialogueBox.MODE_IN)
		DialogueBox.speak_queue()
		await DialogueBox.queue_finished
		if has_node("Timer"): $Timer.scroll_out()
		$SizeMeter/SizeAnimation.play("Disappear")
		await $SizeMeter/SizeAnimation.animation_finished
		KingFace.get_node("RoyalRainbowAnimation").play("rainbow")
		await get_tree().create_timer(4).timeout
		capture_katamari_image()
		await KingFace.get_node("MoyaInOutAnimation").animation_finished
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")
		get_node("/root/KatamariStageRoot").queue_free()
	else:
		DialogueBox.queue_dialog_string(GKGlobal.get_localized_string(mode.get("lose_dialogue", {})), DialogueBox.MODE_IN)

func capture_katamari_image() -> void:
	%KatamariCamera.cull_mask = 1
	%KatamariCamera.attributes.set("dof_blur_far_enabled", false)
	%KatamariCamera.environment = preload("res://scenes/environment/env_preview_env.tres")
	$SubViewport.transparent_bg = true
	await RenderingServer.frame_post_draw
	GKGlobal.create_result_katamari_image($SubViewport.get_texture().get_image())
	$SubViewport.transparent_bg = false
	%KatamariCamera.environment = null
	%KatamariCamera.attributes.set("dof_blur_far_enabled", true)
	%KatamariCamera.cull_mask = 786431

func _process(delta):
	$SubViewport.size = %ViewportRect.get_viewport_rect().size
	$SubViewportFeedback.size = %ViewportRect.get_viewport_rect().size
	
	# Update camera angles
	CameraRotation -= StickAngle * 2.5 * delta
	
	# Transform camera
	%KatamariCamera.transform = Transform3D.IDENTITY.translated_local(Vector3(0, CameraShift, 2)).scaled(Vector3(CameraScale, CameraScale, CameraScale) * $"..".scale)
	%KatamariCameraPivot.transform = Transform3D.IDENTITY.translated(position * $"..".scale).translated_local($KatamariBody.position * $"..".scale).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt).interpolate_with(%KatamariCameraPivot.transform,
	 clamp(CameraSmoothing*((1.0 / 60)/delta), 0, 1))
	
	DashFatigue -= (5.0 if not Fatigued else 7.5) * delta
	
	# Discharge / recharge dash
	if not Fatigued:
		if DashCharge < 0:
			DashCharge += 15 * delta
		elif DashCharge < 25:
			DashCharge = clamp(DashCharge - (delta * 20) * int(MovementEnabled), 0, 100)
		elif DashCharge < 100 and not is_equal_approx(DashCharge, 100):
			if MovementEnabled:
				MovementEnabled = false
				$KatamariDashAudio.stream = preload("uid://cfisonr1vjblw")
				$KatamariDashAudio.play()
			DashCharge += delta * 25
		if DashCharge <= 0 or not CanDash: DashDir = 0
		if CanDash and (MovementEnabled or DashCharge >= 25) and DashCharge >= 0 and ((Input.is_action_just_pressed("LS Dash Down") and DashDir < 1) or (Input.is_action_just_pressed("LS Dash Up") and DashDir > -1)):
			DashCharge += 6.25
			if Input.is_action_just_pressed("LS Dash Down"): DashDir = 1
			if Input.is_action_just_pressed("LS Dash Up"): DashDir = -1
	
	%KatamariDashEfPivot.scale = Vector3.ONE * Size * 1.15 * $"..".scale.y
	%KatamariDashEfPivot.rotation.y = %KatamariCameraPivot.rotation.y
	%KatamariDashEfPivot.rotation.x -= (4*PI) * delta
	%KatamariDashEfPivot/KatamariDashEfA.material_override.albedo_color = %KatamariDashEfPivot/KatamariDashEfA.material_override.albedo_color.lerp(Color(1, 1.2, 2, 1) * ((clampf(DashCharge-25, 0, 30) / 30)), 0.2)
	%KatamariDashEfPivot/KatamariDashEfB.material_override.albedo_color = %KatamariDashEfPivot/KatamariDashEfB.material_override.albedo_color.lerp(Color(1, 1.2, 2, 1) * ((clampf(DashCharge-55, 0, 30) / 30)), 0.2)
	
	$KatamariBody/ShadowDecal.size = Vector3(0.9, 5, 0.9) * Size
	$KatamariBody/ShadowDecal.position = Vector3.DOWN * 2.5 * Size
	
	# Adjust cam. shader parameters
	if not is_zero_approx(%ViewportRect.material.get("shader_parameter/FX_opacity")):
		%ViewportRect.set("shader_parameter/FX_zoom", delta+1)
	
	$FloorBumpDetect/FloorBumpCollide/GPUParticles3D.process_material.set("shader_parameter/Size", Size)
	
	if $Debug.visible:
		# Update debug info
		$Debug/StickDisplay/PanelL/StickL.set_position(Vector2(25, 25) + (25 * LeftStick))
		$Debug/StickDisplay/PanelR/StickR.set_position(Vector2(25, 25) + (25 * RightStick))
		$Debug/StickDisplay/StickM.set_position(Vector2(95, 45) + (25 * StickMidpoint))
		$Debug/StickDisplay/Line2D.points = [Vector2(50, 50) + (25 * LeftStick), Vector2(150, 50) + (25 * RightStick)]
		$Debug/StickDisplay/Label.rotation = StickAngle + (PI/2)
		$Debug/StickDisplay/Label2.text = "a: %frad (%fdeg)" % [StickAngle, rad_to_deg(StickAngle)]
		$Debug/Label3.text = "x:%f\ny:%f\nz:%f\nVx:%f\nVy:%f\nVz:%f\nVr:%f" % [$KatamariBody.position.x, $KatamariBody.position.y, $KatamariBody.position.z, $KatamariBody.linear_velocity.x, $KatamariBody.linear_velocity.y, $KatamariBody.linear_velocity.z, ($KatamariBody.linear_velocity*Vector3(1,0,1)).length()]
		$Debug/StickDisplay/DashChargeBar.value = DashCharge
		$Debug/StickDisplay/DashTireBar.value = DashFatigue

func _physics_process(delta):
	# Handle movement inputs
	LeftStick = GKGlobal.snap_input_angle(Input.get_vector("LS Left", "LS Right", "LS Up", "LS Down", 0.5))
	RightStick = GKGlobal.snap_input_angle(Input.get_vector("RS Left", "RS Right", "RS Up", "RS Down", 0.5))
	StickMidpoint = (LeftStick + Vector2.LEFT).lerp(RightStick + Vector2.RIGHT, 0.5) * int(MovementEnabled)
	if StickMidpoint.length() <= 0.501: StickMidpoint = Vector2.ZERO
	StickAngle = ((RightStick + Vector2(4,0))-LeftStick).angle() * int(CameraMovementEnabled)
	
	# DEBUG: Adjust size
	if Input.is_action_pressed("DEBUG Bigger"): Size += delta
	if Input.is_action_pressed("DEBUG Smaller"): Size = maxf(Size - delta, 0.05)
	
	# Adjust physics settings
	$KatamariBody.gravity_scale = $"..".scale.y * Size
	$KatamariBody/KatamariMeshPivot/KatamariMesh.scale = Vector3.ONE * Size * 1.15 * $"..".scale.y
	$KatamariBody/KatamariBaseCollision.scale = Vector3.ONE * Size * $"..".scale.y
	
	$FloorBumpDetect/FloorBumpCollide.scale = Vector3.ONE * Size
	#$FloorBumpDetect.position = $KatamariBody.position + (0.3 * Vector3.DOWN * Size)
	$KatamariBody/FloorBumpCast.scale = Vector3.ONE * Size * $"..".scale.y
	$KatamariBody/FloorBumpCast.position = Vector3.DOWN * 2.5 * Size
	if $KatamariBody/FloorBumpCast.get_collision_count() > 0:
		$FloorBumpDetect.global_position = $KatamariBody/FloorBumpCast.get_collision_point(0) + (0.1 * Vector3.UP * Size)
	
	$WallBumpDetect/WallBumpCollide.scale = Vector3.ONE * Size
	#$WallBumpDetect.position = $KatamariBody.position + (0.2 * (($KatamariBody.linear_velocity * Vector3(1,0,1)).normalized() if $KatamariBody.linear_velocity.length() > 0 else Vector3.ZERO) * Size)
	$KatamariBody/WallBumpCast.scale = Vector3.ONE * Size * $"..".scale.y
	$KatamariBody/WallBumpCast.position = (2.5 * ($KatamariBody.linear_velocity * Vector3(1,0,1)).normalized() * Size)
	$KatamariBody/WallBumpCast.target_position = (-2.5 * ($KatamariBody.linear_velocity * Vector3(1,0,1)).normalized() * Size)
	if $KatamariBody/WallBumpCast.get_collision_count() > 0:
		$WallBumpDetect.global_position = (
			Vector3($KatamariBody/WallBumpCast.get_collision_point(0).x,
			$KatamariBody.global_position.y,
			$KatamariBody/WallBumpCast.get_collision_point(0).z
			) - (0.2 * Size * $"..".scale.y * ($KatamariBody.linear_velocity * Vector3(1,0,1)).normalized())) if $KatamariBody.linear_velocity.length() > 0 else $KatamariBody.global_position
	
	$KatamariBody.center_of_mass = Vector3(0, Size*-0.5, 0) * $"..".scale.y
	
	$WallClimbDetect/WallClimbCollide.scale = Vector3.ONE * Size
	#$WallClimbDetect.position = $KatamariBody.position + ((Vector3(0, 0.1, 0) + (0.3 * Vector3.FORWARD.rotated(Vector3.UP, CameraRotation))) * Size)
	$KatamariBody/WallClimbCast.scale = Vector3.ONE * Size * $"..".scale.y
	$KatamariBody/WallClimbCast.position = (2.5 * (Vector3.FORWARD.rotated(Vector3.UP, CameraRotation)) * Size)
	$KatamariBody/WallClimbCast.target_position = (-2.5 * (Vector3.FORWARD.rotated(Vector3.UP, CameraRotation)) * Size)
	if $KatamariBody/WallClimbCast.get_collision_count() > 0:
		$WallClimbDetect.global_position = Vector3($KatamariBody/WallClimbCast.get_collision_point(0).x,
			$KatamariBody.global_position.y,
			$KatamariBody/WallClimbCast.get_collision_point(0).z
			) - Vector3(0, 0.35 * Size * $"..".scale.y, 0) - ((0.15 * Vector3.FORWARD.rotated(Vector3.UP, CameraRotation)) * Size * $"..".scale.y)
	
	# Rotate katamari model
	var zRot:float = ($KatamariBody.linear_velocity.x * -PI / $"..".scale.x * delta) / (Size * 1.15)
	var xRot:float = ($KatamariBody.linear_velocity.z * PI / $"..".scale.z * delta) / (Size * 1.15)
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
			if floorCollision.get_angle(col) < 3 * PI/8:
				floorAngle = floorAngle.slerp(floorCollision.get_normal(col), 0.5)
	
	# Calculate movement vector (old method)
	var tempMovement:Vector2 = StickMidpoint.rotated(CameraRotation * -1)
	# Final movement (old method)
	#var finalMovement:Vector2 = tempMovement * Vector2($"..".scale.x, $"..".scale.z) * sqrt(Size) * Speed + ((tempMovement * Vector2(InclineSpeedMultiplier.sample((floorAngle.x * signf(tempMovement.x * -1)/2) + 0.5), InclineSpeedMultiplier.sample((floorAngle.z * signf(tempMovement.y * -1)/2) + 0.5)) - tempMovement) * 5 / pow(Speed/5, 1.0/3) * pow($KatamariBody.gravity_scale, 3))
	# Create movement force
	#$KatamariBody.constant_force = Vector3(finalMovement.x, 0, finalMovement.y)
	
	var finalMovement:Vector2 = tempMovement * Vector2($"..".scale.x * Size, $"..".scale.z * Size) * Speed * Vector2(InclineSpeedMultiplier.sample((floorAngle.x * signf(tempMovement.x * -1)/2) + 0.5), 
	InclineSpeedMultiplier.sample((floorAngle.z * signf(tempMovement.y * -1)/2) + 0.5)) * pow(1, Speed - 1)
	# Create movement force
	$KatamariBody.constant_force = Vector3(finalMovement.x, 0, finalMovement.y).rotated(Vector3(1,0,0), Vector2(floorAngle.y, floorAngle.x).angle()).rotated(Vector3(0,0,1), Vector2(floorAngle.y, floorAngle.z).angle()) * SpeedMultiplier
	
	if is_zero_approx($KatamariBody.linear_velocity.length()) and $WallClimbDetect.has_overlapping_bodies() and StickMidpoint.y < -0.5:
		Climbing = true
	if Climbing:
		if $WallClimbDetect.get_overlapping_bodies().size() > 0 and StickMidpoint.y < -0.5 and MovementEnabled:
			$KatamariBody.gravity_scale = 0
			$KatamariBody.apply_central_force(Vector3.UP * Size * $"..".scale.y * Speed * SpeedMultiplier * 40 * delta)
			
			var zRotClimb:float = (5 * delta * sin(%KatamariCamera.global_rotation.y))
			var xRotClimb:float = (-5 * delta * cos(%KatamariCamera.global_rotation.y))
			$KatamariBody/KatamariMeshPivot.rotate_z(zRotClimb)
			$KatamariBody/KatamariMeshPivot.rotate_x(xRotClimb)
			
			# Rotate object collision
			for collider:Node3D in $KatamariBody.get_children():
				if collider is CollisionShape3D and collider.name != "KatamariBaseCollision":
					#collider.rotate_z(zRot)
					#collider.rotate_x(zRot)
					collider.transform = collider.transform.rotated(Vector3(0,0,1), zRotClimb).rotated(Vector3(1,0,0), xRotClimb)
			
			$KatamariBody.constant_force *= abs(Vector3(0, 1, 1).rotated(Vector3.UP, CameraRotation))
		else: Climbing = false
	
	# Create dash movement/force
	if CanDash and not Fatigued:
		if DashCharge < 100 and DashCharge >= 25 and not is_equal_approx(DashCharge, 100):
			$KatamariBody.apply_central_force(Vector3(
				(Speed * -20 * sin(%KatamariCamera.global_rotation.y)) * Size,
				0,
				(Speed * -20 * cos(%KatamariCamera.global_rotation.y)) * Size
			) * $"..".scale.y * delta)
			
			var zRotDash:float = (24 * delta * sin(%KatamariCamera.global_rotation.y))
			var xRotDash:float = (-24 * delta * cos(%KatamariCamera.global_rotation.y))
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
			$KatamariDashAudio.stream = preload("uid://t5sdks8wbp58")
			$KatamariDashAudio.play()
			$KatamariBody.apply_central_impulse(Vector3(
				(Speed * -4.5 / $"..".scale.x * sin(%KatamariCamera.global_rotation.y)) * Size,
				0,
				(Speed * -4.5 / $"..".scale.z * cos(%KatamariCamera.global_rotation.y)) * Size
			) * $"..".scale.y)
			DashCharge = -10
			DashFatigue += 30
			MovementEnabled = true
	
	# Detect size/camera area changes
	if Size < CurrentZoneBounds.x and CurrentZone > 0:
		changeCamArea(CurrentZone - 1) # Decrease camera area
	elif Size > CurrentZoneBounds.y:
		changeCamArea(CurrentZone + 1) # Decrease camera area
	
	# Detect quick turn
	if Input.is_action_just_pressed("Quick Turn Left") and Input.is_action_just_pressed("Quick Turn Right") and CanQuickTurn:
		doQuickTurn()
	
	# Detect royal warp
	if $KatamariBody.position.y <= RoyalWarpHeight and not RoyalWarping:
		RoyalWarping = true
		respawn()

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
	if skipAnimation:
		CameraScale = CameraZones[CurrentZone].Scale
		CameraTilt = deg_to_rad(CameraZones[CurrentZone].Tilt)
		CameraShift = CameraZones[CurrentZone].Shift
		if CameraZones[CurrentZone].DOF: 
			%KatamariCamera.attributes.dof_blur_far_distance = CameraZones[CurrentZone].DOF * $"..".scale.y
			%KatamariCamera.attributes.dof_blur_amount = 0.0 if is_equal_approx(CameraZones[CurrentZone].DOF, 0) else 0.3
	else:
		var CameraTween = get_tree().create_tween()
		CameraTween.parallel().tween_property(self, "CameraScale", CameraZones[CurrentZone].Scale, 1)
		CameraTween.parallel().tween_property(self, "CameraTilt", deg_to_rad(CameraZones[CurrentZone].Tilt), 1)
		CameraTween.parallel().tween_property(self, "CameraShift", CameraZones[CurrentZone].Shift, 1)
		if CameraZones[CurrentZone].DOF: 
			CameraTween.parallel().tween_property(%KatamariCamera.attributes, "dof_blur_far_distance", CameraZones[CurrentZone].DOF, 1)
			CameraTween.parallel().tween_property(%KatamariCamera.attributes, "dof_blur_amount", 0.0 if is_equal_approx(CameraZones[CurrentZone].DOF, 0) else 0.3, 1)

func doQuickTurn():
	if MovementEnabled:
		MovementEnabled = false
		CameraMovementEnabled = false
		# put the quick turn code here
		var QTTiltTween = get_tree().create_tween()
		var QTRotTween = get_tree().create_tween()
		CameraSmoothing = 0.1
		$KatamariQTAudio.stream = preload("uid://ctdba4rcx3s41")
		$KatamariQTAudio.play()
		QTRotTween.tween_property(self, "CameraRotation", CameraRotation + PI, 0.4).set_trans(Tween.TRANS_LINEAR)
		QTTiltTween.tween_property(self, "CameraTilt", ((-16 * PI) / 32), 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		QTTiltTween.tween_property(self, "CameraTilt", deg_to_rad(CameraZones[CurrentZone].Tilt), 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(0.4).timeout
		CameraSmoothing = 0.85
		MovementEnabled = true
		CameraMovementEnabled = true

func loadCore(texture:String = "res://assets/textures/core/core_test.png", model:String = "res://assets/models/core/core_generic.obj"):
	$KatamariBody/KatamariMeshPivot/KatamariMesh.mesh = load(model)
	$KatamariBody/KatamariMeshPivot/KatamariMesh.material_override.albedo_texture = load(texture)

func playRollSound():
	var soundNum:int = randi_range(0,2)
	
	var audioPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	audioPlayer.bus = "SFX"
	audioPlayer.stream = RollSounds.get(SoundSize)[soundNum]
	audioPlayer.volume_db = -2
	$KatamariBody/KatamariMeshPivot.add_child(audioPlayer)
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

func playBumpSound(sound:int):
	var audioPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
	#audioPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	audioPlayer.bus = "SFX"
	audioPlayer.stream = BumpSounds.get(SoundSize)[sound]
	audioPlayer.volume_db = -2
	$KatamariBody/KatamariMeshPivot.add_child(audioPlayer)
	audioPlayer.play()
	await audioPlayer.finished
	audioPlayer.queue_free()

func respawn(noAnimation:bool = false):
	if not noAnimation:
		CameraSmoothing = 1
		await create_tween().tween_property(%ViewportRect, "material:shader_parameter/fade", 1, 0.25).finished
	CameraSmoothing = 0
	var randomSpawn:Vector4 = SpawnPoints.pick_random()
	$KatamariBody.position = Vector3(randomSpawn.x, randomSpawn.y, randomSpawn.z) + Vector3(0,Size / 2,0)
	CameraRotation = deg_to_rad(randomSpawn.w)
	$KatamariBody.linear_velocity = Vector3.ZERO
	await get_tree().process_frame
	await get_tree().process_frame
	CameraSmoothing = 0.85
	if not noAnimation: 
		await create_tween().tween_property(%ViewportRect, "material:shader_parameter/fade", 0, 0.25).finished
	RoyalWarping = false

func grabObject(ObjectSize:float, ObjectID:StringName, ObjectInstance:StringName):
	ObjectQueue.push_back(ObjectID)
	Size += ObjectSize * GrowthMultiplier
	$ObjectIndicator.push_object(ObjectID, ObjectInstance, %KatamariCamera)
	if ScoringList != {} and ScoringList.get(String(ObjectID)) != null:
		Score += ScoringList.get(String(ObjectID))

func _on_wall_bump(_body):
	var vel:float = ($KatamariBody.linear_velocity * Vector3(1,0,1)).length()
	if vel > (Speed * 2 * Size * $"..".scale.y):
		# Random chance code would go here, but temporarily
		# let's just play the crash sound no matter what
		playBumpSound(2)
	elif vel > (Speed * 0.33 * Size * $"..".scale.y): playBumpSound(1)

func _on_floor_bump(_body):
	if $KatamariBody.linear_velocity.y < (-5 * Size * $"..".scale.y): 
		playBumpSound(0)
		$FloorBumpDetect/FloorBumpCollide/GPUParticles3D.emitting = true

