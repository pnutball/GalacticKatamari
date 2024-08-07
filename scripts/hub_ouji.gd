class_name HubOuji
extends CharacterBody3D
## The input vector for the left stick (movement).
var LeftStick:Vector2 = Vector2(0, 0)
## The input vector for the right stick (camera).
var RightStick:Vector2 = Vector2(0, 0)
## The camera's X and Y rotations.
## X range: -35deg to 90deg
var CamRotation:Vector2 = Vector2(0, 5)
## Mouse velocity.
var MouseVelocity:Vector2 = Vector2.ZERO
## Base movement speed.
const Speed:float = 240

func _physics_process(delta):
	LeftStick = GKGlobal.snap_input_angle(Input.get_vector("LS Right", "LS Left", "LS Down", "LS Up", 0.5)).rotated(deg_to_rad(-1 * CamRotation.x))
	RightStick = GKGlobal.snap_input_angle(Input.get_vector("RS Right", "RS Left", "RS Down", "RS Up", 0.5))
	velocity = Vector3(LeftStick.x, 0, LeftStick.y) * Speed
	if Input.is_action_pressed("Hub Run"): 
		velocity *= 2
	var VelLength:float = Vector2(velocity.x, velocity.z).length()
	velocity *= delta
	$HubOujiAnim.set("parameters/Move/Move/blend_amount", lerpf($HubOujiAnim.get("parameters/Move/Move/blend_amount"), clampf(VelLength - Speed, 0, Speed) / Speed, 15*delta))
	$HubOujiAnim.set("parameters/Move/MoveSpeed/scale", VelLength / Speed)
	if not is_zero_approx(VelLength):
		$Ouji.rotation.y = lerp_angle($Ouji.rotation.y,
		Vector2(velocity.z, velocity.x).angle(),
		(30)*delta)
	
	move_and_slide()
	apply_floor_snap()
	
	if is_zero_approx((get_real_velocity() * Vector3(1,0,1)).length()):
		if $WalkSound.playing: $WalkSound.stop()
	else:
		if not $WalkSound.playing: $WalkSound.play()
		$WalkSound.pitch_scale = ((VelLength / Speed) / 3) + 0.6666666
	

func _input(event):
	if event.is_action_pressed("Unlock Mouse"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton:
		if event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion:
		MouseVelocity = event.relative

func _process(delta):
	CamRotation += 80 * RightStick * delta #* Vector2(1,-1)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		CamRotation += 8 * MouseVelocity * delta * Vector2(-1, 1)
		MouseVelocity = Vector2.ZERO
	CamRotation.y = clampf(CamRotation.y, -28, 85)
	$HubOujiCamPivot.rotation = lerp($HubOujiCamPivot.rotation, 
	Vector3(deg_to_rad(CamRotation.y), deg_to_rad(CamRotation.x), 0),
	(15)*delta)
