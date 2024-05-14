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
## Movement speed.
const Speed:float = 240

func _physics_process(delta):
	LeftStick = Input.get_vector("LS Right", "LS Left", "LS Down", "LS Up", 0.5).rotated(deg_to_rad(-1 * CamRotation.x))
	RightStick = Input.get_vector("RS Right", "RS Left", "RS Down", "RS Up", 0.5)
	velocity = Vector3(LeftStick.x, 0, LeftStick.y) * Speed * delta
	if not is_zero_approx(Vector2(velocity.x, velocity.z).length()): 
		$Ouji.rotation.y = lerp_angle($Ouji.rotation.y,
		Vector2(velocity.z, velocity.x).angle(),
		(30)*delta)
	move_and_slide()

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
