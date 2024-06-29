extends Node3D

@onready var editor:Control = get_node("/root/EditorRoot")
@onready var camera:Camera3D = get_node("/root/EditorRoot/BGPanel/MarginContainer/EditorVBox/SplitMain/SplitRight/MiddleVBox/EditorView/ViewPort/EditorPrevRoot/EditorCamera/Camera3D")
@onready var tree:Tree = get_node("/root/EditorRoot/BGPanel/MarginContainer/EditorVBox/SplitMain/SplitLeft/TreePanel/LevelTree")

var objectList:Dictionary = load("res://data/objects.json").data["objects"]

## The source tree object used for this 3D object.
@export var Source:GKEditorTreeObject = null
var mesh:String
var texture:String
var texture_selected:String

@onready var selected:bool = false
var old_position:Vector3 = position
var old_rotation:Vector3 = rotation

enum Direction {X, Y, Z}
enum TransformType {Translate, Rotate}

var dragging:bool = false
var drag_direction:Direction = Direction.X
var drag_type:TransformType = TransformType.Translate
var drag_normal:Vector2 = Vector2.ZERO
var drag_rot_mult:int = 0
var mouse_velocity:Vector2 = Vector2.ZERO
var mouse_velocity_combined:Vector2 = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_velocity = event.relative
		if dragging:
			mouse_velocity_combined += mouse_velocity

func _ready():
	for gizmo in $Gizmos.get_children():
		if gizmo is MeshInstance3D:
			gizmo.get_node("Detect").mouse_entered.connect(_gizmo_hover.bind(gizmo, true))
			gizmo.get_node("Detect").mouse_exited.connect(_gizmo_hover.bind(gizmo, false))

func _process(delta):
	if mesh != objectList.get("", objectList["debug_cube"])["view_mesh"]:
		mesh = objectList.get("", objectList["debug_cube"])["view_mesh"]
		%RollableObjectMesh.mesh = load(mesh)
	if texture != objectList.get("", objectList["debug_cube"])["texture"]:
		texture = objectList.get("", objectList["debug_cube"])["texture"]
		%RollableObjectMesh.material_override.set("shader_parameter/Texture", load(texture))
	if texture_selected != objectList.get("", objectList["debug_cube"])["texture_rolledup"]:
		texture_selected = objectList.get("", objectList["debug_cube"])["texture_rolledup"]
		%RollableObjectMesh.material_override.set("shader_parameter/Texture_Rolled", load(texture_selected))
	$Gizmos.position = global_position
	$Gizmos.rotation = global_rotation if editor.transform_local else Vector3.ZERO
	if Source != null and not dragging:
		position = Source.position
		rotation = Source.rotation
	else:
		if drag_type == TransformType.Translate:
			var positional_magnitude:float = (mouse_velocity_combined * Vector2(1,-1)).rotated(-(drag_normal.angle())).x
			var magnitude_3D:Vector3 = positional_magnitude * (Vector3.UP if drag_direction == Direction.Y else (Vector3.RIGHT if drag_direction == Direction.X else Vector3.BACK))
			if editor.transform_local: magnitude_3D = magnitude_3D.rotated(Vector3.UP, $Visual.global_rotation.y)
			var distance_3D:Vector3 = 0.0075 * magnitude_3D
			if editor.snap_enabled: distance_3D = snapped(distance_3D, Vector3.ONE * editor.snap_move)
			global_position = old_position + distance_3D
		else:
			var angle:float = mouse_velocity_combined.rotated(-(drag_normal.angle())).angle() * -drag_rot_mult
			if editor.snap_enabled: angle = snappedf(angle, editor.snap_angle)
			var final_rotation:Vector3
			if drag_direction == Direction.X: final_rotation = old_rotation + (Vector3.RIGHT * angle)
			elif drag_direction == Direction.Y: final_rotation = old_rotation + (Vector3.UP * angle)
			else: final_rotation = old_rotation + (Vector3.BACK * angle)
			global_rotation = final_rotation
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Source.position = position
			Source.rotation = rotation
			dragging = false
			editor._on_treeprop_change_made()
			editor._reload_properties_panel()
	mouse_velocity = Vector2.ZERO
	if selected and tree.get_selected() != Source.synced_tree_item:
		deselect()

func begin_translate(direction:Direction):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not dragging:
		get_viewport().set_input_as_handled()
		old_position = global_position
		drag_direction = direction
		mouse_velocity_combined = Vector2.ZERO
		if direction == Direction.X: 
			drag_normal = Vector2.RIGHT
		elif direction == Direction.Z: 
			drag_normal = Vector2.UP
		else: 
			drag_normal = Vector2.DOWN
		if direction != Direction.Y: drag_normal = drag_normal.rotated(-(camera.global_rotation.y))
		if editor.transform_local and direction != Direction.Y: drag_normal = drag_normal.rotated($Visual.global_rotation.y)
		drag_type = TransformType.Translate
		dragging = true

func begin_rotate(direction:Direction):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not dragging:
		get_viewport().set_input_as_handled()
		old_rotation = global_rotation
		drag_direction = direction
		mouse_velocity_combined = camera.get_parent().get_parent().get_parent().get_mouse_position() - camera.unproject_position($Gizmos.global_position)
		drag_normal = mouse_velocity_combined.normalized()
		if direction == Direction.X: 
			drag_rot_mult = signf(Vector2.UP.rotated(-(camera.global_rotation.y)).x)
		elif direction == Direction.Z: 
			drag_rot_mult = signf(Vector2.RIGHT.rotated(-(camera.global_rotation.y)).x)
		else: 
			drag_rot_mult = signf(-(camera.global_rotation.x))
		drag_type = TransformType.Rotate
		dragging = true

func select():
	if not selected:
		selected = true
		$"3DAnimPivot/RollableObjectMesh".material_override.set("shader_parameter/Rolled", true)
		$Gizmos.visible = true
		if tree.get_selected() != Source.synced_tree_item:
			tree.set_selected(Source.synced_tree_item, 0)

func deselect():
	if selected:
		selected = false
		$"3DAnimPivot/RollableObjectMesh".material_override.set("shader_parameter/Rolled", false)
		$Gizmos.visible = false

func _tra_x_clicked(): begin_translate(Direction.X)
func _tra_y_clicked(): begin_translate(Direction.Y)
func _tra_z_clicked(): begin_translate(Direction.Z)
func _rot_x_clicked(): begin_rotate(Direction.X)
func _rot_y_clicked(): begin_rotate(Direction.Y)
func _rot_z_clicked(): begin_rotate(Direction.Z)

func _gizmo_hover(node:MeshInstance3D, hovered:bool):
	node.material_override.set("shader_parameter/selected", hovered)


func _on_object_input(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select()
