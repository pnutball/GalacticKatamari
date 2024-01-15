@icon("res://KatamariObject.svg")
extends Node3D
#region Variables
## Sets the size of the katamari, in meters.
@export_range(0.01, 0, 0.001, "or_greater", "hide_slider", "suffix:m") var Size:float = 1
var MinimumSize:float = Size
## Sets how much size objects give when rolled up. 
##
## 1 gives the full amount of size, 0 gives none.
@export_range(0, 1) var GrowthMultiplier:float = 1

@export_group("Physics")
## Sets the katamari's speed relative to a size of 1m. This also affects the max speed.
@export_range(0, 0, 0.01, "or_greater", "hide_slider", "suffix:m/s²/m") var Speed:float = 1
## Sets how much the katamari's acceleration/top speed is multiplied.
@export var InclineSpeedMultiplier:Curve

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

## The input vector for the left stick.
var LeftStick:Vector2 = Vector2(0, 0)
## The input vector for the right stick.
var RightStick:Vector2 = Vector2(0, 0)
## The center point of both sticks.
var StickMidpoint:Vector2 = LeftStick.lerp(RightStick, 0.5)
## The angle of the line between both sticks, in radians.
var StickAngle:float = ((RightStick + Vector2(4,0))-LeftStick).angle()
#endregion

func _ready():
	changeCamArea(0, true)
	$KatamariCameraPivot.transform = Transform3D.IDENTITY.translated($KatamariBody.position).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt)

func _process(delta):
	
	
	# Update camera angles
	CameraRotation -= StickAngle * 2.5 * delta
	
	# Transform camera
	$KatamariCameraPivot/KatamariCamera.transform = Transform3D.IDENTITY.translated_local(Vector3(0, CameraShift, 2)).scaled(Vector3(CameraScale, CameraScale, CameraScale))
	$KatamariCameraPivot.transform = Transform3D.IDENTITY.translated_local($KatamariBody.position).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt).interpolate_with($KatamariCameraPivot.transform, 0.85)
	$KatamariCameraPivot/KatamariCamera.attributes.dof_blur_far_distance = CameraScale * $"..".scale.y * 0.01
	
	# Update debug info
	$Control/PanelL/StickL.set_position(Vector2(25, 25) + (25 * LeftStick))
	$Control/PanelR/StickR.set_position(Vector2(25, 25) + (25 * RightStick))
	$Control/StickM.set_position(Vector2(95, 45) + (25 * StickMidpoint))
	$Control/Line2D.points = [Vector2(50, 50) + (25 * LeftStick), Vector2(150, 50) + (25 * RightStick)]
	$Control/Label.rotation = StickAngle + (PI/2)
	$Control/Label2.text = "a: %frad (%fdeg)" % [StickAngle, rad_to_deg(StickAngle)]
	$Control/Label3.text = "x:%f\ny:%f\nz:%f\nVx:%f\nVy:%f\nVz:%f\nVr:%f" % [$KatamariBody.position.x, $KatamariBody.position.y, $KatamariBody.position.z, $KatamariBody.linear_velocity.x, $KatamariBody.linear_velocity.y, $KatamariBody.linear_velocity.z, ($KatamariBody.linear_velocity*Vector3(1,0,1)).length()]
	$Control/Label4.text = "size:%dm%02dcm%01dmm\ndamp:%f" % [floori(Size), floori(Size * 100) % 100, floori(Size * 1000) % 10, $KatamariBody.linear_damp]

func _physics_process(delta):
	# Handle inputs
	LeftStick = Input.get_vector("LS Left", "LS Right", "LS Up", "LS Down", 0.5)
	RightStick = Input.get_vector("RS Left", "RS Right", "RS Up", "RS Down", 0.5)
	StickMidpoint = (LeftStick + Vector2.LEFT).lerp(RightStick + Vector2.RIGHT, 0.5)
	if StickMidpoint.length() <= 0.501: StickMidpoint = Vector2.ZERO
	StickAngle = ((RightStick + Vector2(4,0))-LeftStick).angle()
	
	# DEBUG: Adjust size
	if Input.is_action_pressed("DEBUG Bigger"): Size += delta
	if Input.is_action_pressed("DEBUG Smaller"): Size = maxf(Size - delta, 0.05)
	
	# Adjust physics settings
	$KatamariBody.gravity_scale = $"..".scale.y
	$KatamariBody/KatamariMeshPivot/KatamariMesh.scale = Vector3.ONE * Size * 1.15
	$KatamariBody/KatamariBaseCollision.scale = Vector3.ONE * Size
	
	# Rotate katamari model (including objects and collision when that's implemented)
	var zRot:float = ($KatamariBody.linear_velocity.x * -8 / $"..".scale.x * delta) / Size
	var xRot:float = ($KatamariBody.linear_velocity.z * 8 / $"..".scale.z * delta) / Size
	$KatamariBody/KatamariMeshPivot.rotate_z(zRot)
	$KatamariBody/KatamariMeshPivot.rotate_x(xRot)
	
	# Rotate object collision
	for collider:Node3D in $KatamariBody.get_children():
		if collider is CollisionShape3D and collider.name != "KatamariBaseCollision":
			#collider.rotate_z(zRot)
			#collider.rotate_x(zRot)
			collider.transform = collider.transform.rotated(Vector3(0,0,1), zRot).rotated(Vector3(1,0,0), xRot)
	
	# Determine floor collision
	var floorCollision:KinematicCollision3D = $KatamariBody.move_and_collide(Vector3.DOWN * 0.1, true)
	var floorAngle:Vector3 = Vector3.UP
	if floorCollision: floorAngle = floorCollision.get_normal()
	
	# Calculate movement vector
	var tempMovement:Vector2 = StickMidpoint.rotated(CameraRotation * -1)
	var finalMovement:Vector2 = tempMovement * Vector2($"..".scale.x, $"..".scale.z) * sqrt(Size) * Speed + ((tempMovement * Vector2(InclineSpeedMultiplier.sample((floorAngle.x * signf(tempMovement.x * -1)/2) + 0.5), InclineSpeedMultiplier.sample((floorAngle.z * signf(tempMovement.y * -1)/2) + 0.5)) - tempMovement) / pow(Speed, 1.0/3))
	
	# Create movement force
	$KatamariBody.constant_force = Vector3(finalMovement.x, 0, finalMovement.y)
	
	# Detect size/camera area changes
	if Size < CurrentZoneBounds.x and CurrentZone > 0:
		changeCamArea(CurrentZone - 1) # Decrease camera area
	elif Size > CurrentZoneBounds.y:
		changeCamArea(CurrentZone + 1) # Decrease camera area


## Changes the current camera zone to CameraZones[index].
func changeCamArea(index:int, skipAnimation:bool = false):
	if index > CameraZones.size(): push_error("Camera zone index out of bounds")
	CurrentZone = index
	if CurrentZone > HighestZone: 
		HighestZone = CurrentZone
		if not skipAnimation: $KatamariCameraPivot/KatamariCamera/KatamariCameraZoom.play("CameraZoom")
	var nextBound := 1.79769e308
	if CameraZones.size() - 1 > CurrentZone: nextBound = CameraZones[CurrentZone+1].Bound
	CurrentZoneBounds = Vector2(CameraZones[CurrentZone].Bound, nextBound)
	print(CurrentZoneBounds.y)
	if CameraZones[CurrentZone].Attributes: 
		$KatamariCameraPivot/KatamariCamera.attributes = CameraZones[CurrentZone].Attributes
	if skipAnimation:
		CameraScale = CameraZones[CurrentZone].Scale
		CameraTilt = deg_to_rad(CameraZones[CurrentZone].Tilt)
		CameraShift = CameraZones[CurrentZone].Shift
	else:
		var CameraTween = get_tree().create_tween()
		CameraTween.parallel().tween_property(self, "CameraScale", CameraZones[CurrentZone].Scale, 1)
		CameraTween.parallel().tween_property(self, "CameraTilt", deg_to_rad(CameraZones[CurrentZone].Tilt), 1)
		CameraTween.parallel().tween_property(self, "CameraShift", CameraZones[CurrentZone].Shift, 1)
	
