extends Node3D

## The camera's X and Y rotations.
## X range: -35deg to 90deg
var CamRotation:Vector2 = Vector2(0, 0)
## Mouse velocity.
var MouseVelocity:Vector2 = Vector2.ZERO

## Right click active?
var RightClick:bool = false
## Middle click active?
var MiddleClick:bool = false

func disable_clicks():
	RightClick = false
	MiddleClick = false

func input(event):
	if event is InputEventMouseMotion:
		MouseVelocity = event.relative
		print(MouseVelocity)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				RightClick = event.pressed
			MOUSE_BUTTON_MIDDLE:
				MiddleClick = event.pressed

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		if not (MiddleClick or RightClick):
			Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
		elif MiddleClick:
			CamRotation += 8 * MouseVelocity * delta * Vector2(-1, 1)
			CamRotation.y = clampf(CamRotation.y, -90, 90)
			rotation = Vector3(deg_to_rad(CamRotation.y),
			deg_to_rad(CamRotation.x), 0)
			MouseVelocity = Vector2.ZERO
	else:
		if (MiddleClick or RightClick):
			Input.mouse_mode == Input.MOUSE_MODE_HIDDEN
