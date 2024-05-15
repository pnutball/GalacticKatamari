extends Node3D

## The camera's X and Y rotations.
## X range: -35deg to 90deg
var CamRotation:Vector2 = Vector2(0, 0)
## Mouse velocity.
var MouseVelocity:Vector2 = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		MouseVelocity = event.relative

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CONFINED:
		if not (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or 
		Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
			return
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			CamRotation += 8 * MouseVelocity * delta * Vector2(-1, 1)
			MouseVelocity = Vector2.ZERO
			CamRotation.y = clampf(CamRotation.y, -90, 90)
			rotation = Vector3(deg_to_rad(CamRotation.y),
			deg_to_rad(CamRotation.x), 0)
	else:
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) or 
		Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			Input.mouse_mode == Input.MOUSE_MODE_CONFINED
