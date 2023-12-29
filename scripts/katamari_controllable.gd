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
## Sets the katamari's acceleration relative to a size of 1m.
@export_range(0, 0, 0.01, "or_greater", "hide_slider", "suffix:m/s²/m") var Speed:float = 1
## Sets the katamari's top speed relative to a size of 1m.
@export_range(0, 0, 0.01, "or_greater", "hide_slider", "suffix:m/s²/m") var TopSpeed:float = 1
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
## An array of size ranges and their respective camera scales/tilts.
##
## X determines the minimum size (in meters) for the size range.
## Y determines the camera scale relative to the World3D (NOT the katamari!).
## Z determines the camera's tilt in radians.
## W determines the camera's vertical shift, relative to the World3D
@export var CameraZones:Array[Vector4] = [Vector4(0, 1.5, deg_to_rad(-15), .25)]
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
	changeSizeArea(0)
	$KatamariCameraPivot.transform = Transform3D.IDENTITY.translated($KatamariBody.position).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt)

func _process(delta):
	
	
	# Update camera angles
	CameraRotation -= StickAngle * 2.5 * delta
	
	# Transform camera
	$KatamariCameraPivot/KatamariCamera.transform = Transform3D.IDENTITY.translated_local(Vector3(0, CameraShift, 2)).scaled(Vector3(CameraScale, CameraScale, CameraScale))
	$KatamariCameraPivot.transform = Transform3D.IDENTITY.translated_local($KatamariBody.position).rotated_local(Vector3.UP, CameraRotation).rotated_local(Vector3.RIGHT, CameraTilt).interpolate_with($KatamariCameraPivot.transform, 0.85)
	
	# Update debug info
	$Control/PanelL/StickL.set_position(Vector2(25, 25) + (25 * LeftStick))
	$Control/PanelR/StickR.set_position(Vector2(25, 25) + (25 * RightStick))
	$Control/StickM.set_position(Vector2(95, 45) + (25 * StickMidpoint))
	$Control/Line2D.points = [Vector2(50, 50) + (25 * LeftStick), Vector2(150, 50) + (25 * RightStick)]
	$Control/Label.rotation = StickAngle + (PI/2)
	$Control/Label2.text = "a: %frad (%fdeg)" % [StickAngle, rad_to_deg(StickAngle)]
	$Control/Label3.text = "x:%f\ny:%f\nz:%f\nVx:%f\nVy:%f\nVz:%f" % [$KatamariBody.position.x, $KatamariBody.position.y, $KatamariBody.position.z, $KatamariBody.linear_velocity.x, $KatamariBody.linear_velocity.y, $KatamariBody.linear_velocity.z]

func _physics_process(delta):
	# Handle inputs
	LeftStick = Input.get_vector("LS Left", "LS Right", "LS Up", "LS Down", 0.5)
	RightStick = Input.get_vector("RS Left", "RS Right", "RS Up", "RS Down", 0.5)
	StickMidpoint = (LeftStick + Vector2.LEFT).lerp(RightStick + Vector2.RIGHT, 0.5)
	if StickMidpoint.length() <= 0.501: StickMidpoint = Vector2.ZERO
	StickAngle = ((RightStick + Vector2(4,0))-LeftStick).angle()
	
	$KatamariBody.gravity_scale = $"..".scale.y
	$KatamariBody.scale = Vector3.ONE * Size
	$KatamariBody/KatamariBaseCollision.scale = Vector3.ONE * Size * 0.2

	var tempMovement:Vector2 = StickMidpoint.rotated(CameraRotation * -1)
	var floorCollision:KinematicCollision3D = $KatamariBody.move_and_collide(Vector3.DOWN * 0.1, true)
	var floorAngle:Vector3 = Vector3.UP
	if floorCollision: floorAngle = floorCollision.get_normal()
	if ($KatamariBody.linear_velocity * Vector3(1,0,1)).length() < TopSpeed: $KatamariBody.linear_velocity.x += tempMovement.x * Size * delta * $"..".scale.x * Speed * InclineSpeedMultiplier.sample(absf(floorAngle.x))
	if ($KatamariBody.linear_velocity * Vector3(1,0,1)).length() < TopSpeed: $KatamariBody.linear_velocity.z += tempMovement.y * Size * delta * $"..".scale.z * Speed * InclineSpeedMultiplier.sample(absf(floorAngle.z))
	
	


## Changes the current camera zone to CameraZones[index].
func changeSizeArea(index:int):
	if index > CameraZones.size(): push_error("Camera zone index out of bounds")
	CurrentZone = index
	
	var nextBound := 1.79769e308
	if CameraZones.size() - 1 < CurrentZone: nextBound = CameraZones[CurrentZone+1].x
	CurrentZoneBounds = Vector2(CameraZones[CurrentZone].x, nextBound)
	CameraScale = CameraZones[CurrentZone].y
	$KatamariCameraPivot/KatamariCamera.attributes.dof_blur_far_distance = CameraScale * 5 * $"..".scale.y
	CameraTilt = CameraZones[CurrentZone].z
	CameraShift = CameraZones[CurrentZone].w
	
	if CurrentZone > HighestZone: HighestZone = CurrentZone
