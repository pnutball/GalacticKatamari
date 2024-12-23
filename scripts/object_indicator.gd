extends Control

const RAINBOW:String = "[rainbow sat=0.3 val=1 freq=0.5]"

const BG_NORMAL:Texture2D = preload("res://assets/textures/ui/object_view/object_view_bg.png")
const BOX_NORMAL:StyleBox = preload("res://assets/textures/ui/object_view/object_label_box.tres")

const BG_DANGER:Texture2D = preload("res://assets/textures/ui/object_view/object_view_danger.png")
const BOX_DANGER:StyleBox = preload("res://assets/textures/ui/object_view/object_label_box_danger.tres")

var object_list:Dictionary = load("res://data/objects.json").data["objects"]

@onready var in_danger:bool = false:
	get: return in_danger
	set(new):
		in_danger = new
		$Offset/Background/DangerSpinEffect.visible = new
		if new:
			$Offset/Background.texture = BG_DANGER
			$Offset/TextPanel.set("theme_override_styles/panel", BOX_DANGER)
			$WarnAudio.play()
			
		else:
			$Offset/Background.texture = BG_NORMAL
			$Offset/TextPanel.set("theme_override_styles/panel", BOX_NORMAL)
			$WarnAudio.stop()

var text_interrupted:bool = false

var object_display_timer:float = 0:
	get: return object_display_timer
	set(new): object_display_timer = clampf(new, 0, 5)
var object_displayed:bool = false:
	get: return not is_zero_approx(object_display_timer)

var pointer_line_target:MeshInstance3D = null
@onready var pointer_line_camera:Camera3D = $"../SubViewport/KatamariCameraPivot/KatamariCamera"

func _process(delta):
	# Absolute shitty fucking hack. i hate this.
	position = Vector2.ZERO
	size = get_viewport().size * (1080.0 / get_viewport().size.y)
	$Offset.position.y = 826
	
	object_display_timer -= delta
	%"3DView/3DViewport/ObjectMesh".rotation.y = -0.6109 - (-PI/4 * object_display_timer)
	visible = in_danger or object_displayed
	$Offset/TextPanel.visible = object_displayed
	%"3DView".visible = object_displayed
	$PointerLine.visible = object_displayed
	$Offset/Background/DangerArrow.visible = in_danger and not object_displayed
	if in_danger: $Offset/Background/DangerSpinEffect.rotation += (PI*4) * delta
	
	if pointer_line_target != null and not is_zero_approx(clampf((object_display_timer - 4.75) * 4,0,1)):
		var endpoint:Vector2 = pointer_line_camera.unproject_position(pointer_line_target.global_position)
		var start_base:Vector2 = $Offset/Background.global_position + (Vector2.ONE * 71)
		var startpoint:Vector2 = start_base + start_base.direction_to(endpoint) * 70
		$PointerLine/ObjectPointerLine.set_point_position(0, startpoint)
		$PointerLine/ObjectPointerLine.set_point_position(1, endpoint)
		$PointerLine/ObjectPointerDot.position = endpoint - (Vector2.ONE * 17)
	$PointerLine.modulate = Color(1,1,1,clampf((object_display_timer - 4.75) * 4,0,1))

func push_object(object_id:StringName, object_instance:StringName, camera:Camera3D):
	if object_list.get(String(object_id), {}).get("view_mesh") != null and ResourceLoader.exists(object_list.get(String(object_id), {}).get("view_mesh")):
		%"3DView/3DViewport/ObjectMesh".mesh = load(object_list[String(object_id)].view_mesh)
		%"3DView/3DViewport/ObjectMesh".get("surface_material_override/0").set("shader_parameter/Texture", load(object_list[String(object_id)].texture_rolledup))
		%"3DView/3DViewport/ObjectMesh".scale = Vector3.ONE * object_list.get(String(object_id), {}).get("view_scale", 1) * 3
	pointer_line_target = get_node("../KatamariBody/KatamariMeshPivot/%s_M" % String(object_instance))
	pointer_line_camera = camera
	_make_text(object_id)

func _make_text(object_id:StringName):
	if object_list.get(String(object_id), {}).get("name") != null:
		var fullname = GKGlobal.get_localized_string(object_list[String(object_id)].name)
		%Text.text = ""
		var _text_cache := ""
		if false: 
		# when collection code is implemented, detect new objects rolled and change false to match
			%Text.text += RAINBOW
			_text_cache += RAINBOW
		object_display_timer = 5
		if %Text.text == _text_cache:
			for character in fullname:
				if %Text.text != _text_cache:
					break
				%Text.text += character
				_text_cache += character
				$Offset/TextPanel.size = Vector2.ZERO
				$Offset/TextPanel.position = Vector2(maxf(($Offset.size.x - $Offset/TextPanel.size.x)/2, 0), 145 - maxf((45 - $Offset/TextPanel.size.y)/2, 0))
				await get_tree().create_timer(0.05, false).timeout
			
