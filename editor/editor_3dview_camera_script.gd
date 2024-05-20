extends Node3D

## The camera's X and Y rotations.
## X range: -35deg to 90deg
var CamRotation:Vector2 = Vector2(0, 0)
## Mouse velocity.
var MouseVelocity:Vector2 = Vector2.ZERO
## Mouse position.
var MousePosition:Vector2 = Vector2.ZERO


## Right click active?
var RightClick:bool = false
## Middle click active?
var MiddleClick:bool = false
## Zoom amount.
var MouseWheel:int = 0

func disable_clicks():
	RightClick = false
	MiddleClick = false

func input(event):
	if event is InputEventMouseMotion:
		MouseVelocity = event.relative#.posmodv(Vector2(get_viewport().size))
		#print(MouseVelocity)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				RightClick = event.pressed
			MOUSE_BUTTON_MIDDLE:
				MiddleClick = event.pressed
			MOUSE_BUTTON_WHEEL_UP: MouseWheel += 1
			MOUSE_BUTTON_WHEEL_DOWN: MouseWheel -= 1

func _process(delta):
	MousePosition = get_viewport().get_mouse_position()
	
	if (MiddleClick or RightClick):
		if MiddleClick:
			if Input.is_key_pressed(KEY_SHIFT):
				# Pan camera
				var CamPan:Vector2 = Vector2(-0.5, 0.5) * MouseVelocity * delta * (Vector2(1920, 1080) / Vector2(get_window().size))
				translate_object_local(Vector3(CamPan.x, CamPan.y, 0))
				MouseVelocity = Vector2.ZERO
			else:
				# Orbit camera
				CamRotation -= 10 * MouseVelocity * delta * (Vector2(1920, 1080) / Vector2(get_window().size))
				CamRotation.y = clampf(CamRotation.y, -90, 90)
				rotation = Vector3(deg_to_rad(CamRotation.y),
				deg_to_rad(CamRotation.x), 0)
				MouseVelocity = Vector2.ZERO
		
		#if (MousePosition.x != clamp(MousePosition.x, 0, get_viewport().size.x) or 
		#MousePosition.y != clamp(MousePosition.y, 0, get_viewport().size.y)):
		#	get_viewport().warp_mouse(MousePosition.posmodv(Vector2(get_viewport().size)))
	if MouseWheel != 0:
		scale *= pow(0.95, MouseWheel)
		MouseWheel = 0
