extends Node3D

@onready var editor:Control = get_node("/root/EditorRoot")
@onready var camera:Camera3D = get_node("/root/EditorRoot/BGPanel/MarginContainer/EditorVBox/SplitMain/SplitRight/MiddleVBox/EditorView/ViewPort/EditorPrevRoot/EditorCamera/Camera3D")

## The source tree object used for this 3D spawn.
@export var Source:GKEditorTreeSpawn = null
var old_position:Vector3 = position

enum Direction {X, Y, Z}
enum TransformType {Translate, Rotate}

var dragging:bool = false
var drag_direction:Direction = Direction.X
var drag_type:TransformType = TransformType.Translate
var drag_normal:Vector2 = Vector2.ZERO
var mouse_velocity:Vector2 = Vector2.ZERO
var mouse_velocity_combined:Vector2 = Vector2.ZERO

func _ready():
	for gizmo in $Gizmos.get_children():
		if gizmo is MeshInstance3D:
			gizmo.get_node("Detect").mouse_entered.connect(_gizmo_hover.bind(gizmo, true))
			gizmo.get_node("Detect").mouse_exited.connect(_gizmo_hover.bind(gizmo, false))

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative
		if dragging:
			mouse_velocity_combined += mouse_velocity

func _process(_delta):
	if Source != null and not dragging:
		position = Source.position
		$Visual.rotation.y = deg_to_rad(Source.rotation) - (PI*0.5)
	else:
		if drag_type == TransformType.Translate:
			var positional_magnitude:float = (mouse_velocity_combined * Vector2(1,-1)).rotated(-(drag_normal.angle())).x
			var magnitude_3D:Vector3 = positional_magnitude * (Vector3.UP if drag_direction == Direction.Y else (Vector3.RIGHT if drag_direction == Direction.X else Vector3.BACK)) 
			var distance_3D:Vector3 = 0.0075 * magnitude_3D
			if editor.snap_enabled: distance_3D = snapped(distance_3D, Vector3.ONE * editor.snap_move)
			position = old_position + distance_3D
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Source.position = position
			Source.rotation = rad_to_deg($Visual.rotation.y) + 90
			dragging = false
	mouse_velocity = Vector2.ZERO

func begin_translate(direction:Direction):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not dragging:
		get_viewport().set_input_as_handled()
		old_position = position
		drag_direction = direction
		mouse_velocity_combined = Vector2.ZERO
		if direction == Direction.X: 
			drag_normal = Vector2.RIGHT.rotated(-(camera.global_rotation.y))
		elif direction == Direction.Z: 
			drag_normal = Vector2.UP.rotated(-(camera.global_rotation.y))
		else: 
			drag_normal = Vector2.DOWN
		drag_type = TransformType.Translate
		dragging = true

func _tra_x_clicked(): begin_translate(Direction.X)
func _tra_y_clicked(): begin_translate(Direction.Y)
func _tra_z_clicked(): begin_translate(Direction.Z)

func _gizmo_hover(node:MeshInstance3D, hovered:bool):
	node.material_override.set("shader_parameter/selected", hovered)
