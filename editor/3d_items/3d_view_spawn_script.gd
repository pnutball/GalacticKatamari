extends Node3D

## The source tree object used for this 3D spawn.
@export var Source:GKEditorTreeSpawn = null

var dragging:bool = false

func _process(_delta):
	if Source != null and not dragging:
		position = Source.position
		$Visual.rotation.y = deg_to_rad(Source.rotation) - (PI*0.5)
	else:
		Source.position = position
		Source.rotation = rad_to_deg($Visual.rotation.y) + 90

func _dragged():
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass
