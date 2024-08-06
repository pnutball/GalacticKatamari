extends Node3D

const SPEED:float = 720
const BOUNDS:Vector2 = Vector2(1600,800) #Vector2(1500,700)

var _animation_active:bool = false
var load_text:String = ""
var load_colors:PackedColorArray = []

@onready var king_vector:Vector2 = Vector2.RIGHT.rotated(randf_range(0, 2*PI))
@onready var text_vector:Vector2 = Vector2.RIGHT.rotated(randf_range(0, 2*PI))

func _process_tags(input:String) -> void:
	var formattingSplits:PackedStringArray = input.split("|")
	var currentColor:Color = Color.WHITE
	for index in formattingSplits.size():
		if index % 2 == 1 and Color.html_is_valid(formattingSplits[index]): 
			currentColor = Color.html(formattingSplits[index])
		else:
			var colorArray:PackedColorArray = []
			colorArray.resize(formattingSplits[index].length())
			colorArray.fill(currentColor)
			load_text = load_text + formattingSplits[index]
			load_colors.append_array(colorArray)
func _ready():
	_process_tags(GKGlobal.get_localized_string(preload("res://data/load_text.json").data.load_text.pick_random()))
	if get_tree().paused:
		get_tree().paused = false
	process_mode = Node.PROCESS_MODE_INHERIT
	DialogueBox.visible = true
	KingFace.visible = true
	KingFace.Emotion = &"Neutral"
	KingFace.Shocked = false
	KingFace.get_node("KingSpeechSound").volume_db = -80
	if not KingFace.get_node("MoyaPos/SubViewportContainer").visible or KingFace.get_node("MoyaInOutAnimation").current_animation != "in":
		KingFace.get_node("MoyaPos/SubViewportContainer").visible = false
		KingFace.MoyaPosition = Vector2(0,-350)
		KingFace.get_node("MoyaInOutAnimation").play("in")
		await KingFace.get_node("MoyaInOutAnimation").animation_finished
	StageLoader.queue_stage()
	KingFace.Talking = true
	_animation_active = true
	_letter_loop()
	# To test the load animation by never finishing, uncomment below:
	#return
	await StageLoader.stage_preloaded
	#await get_tree().create_timer(5).timeout
	KingFace.Talking = false
	KingFace.get_node("KingSpeechSound").volume_db = 0
	var kingtween = get_tree().create_tween()
	_animation_active = false
	kingtween.tween_property(KingFace, "MoyaPosition", Vector2(0,-350), 0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(0.8).timeout
	StageLoader.instantiateStage(self)
	await get_tree().process_frame
	$LoadScreen/LoadAnim.play("in_retry" if StageLoader.restarted else "in")

func _letter_loop():
	var index:int = 0
	while _animation_active:
		var letter:LoadLetter = LoadLetter.create(load_text[index % load_text.length()], text_vector * SPEED, load_colors[index % load_colors.size()])
		letter.position = (KingFace.MoyaPosition - Vector2.ONE * 50 - Vector2.UP * 65) * 1.03
		$LoadScreen/Letters.add_child(letter)
		await get_tree().create_timer(0.075).timeout
		index += 1

func _process(delta):
	if _animation_active:
		var king_input = GKGlobal.snap_input_angle(Input.get_vector("LS Left", "LS Right", "LS Up", "LS Down", 0.5))
		var text_input = GKGlobal.snap_input_angle(Input.get_vector("RS Left", "RS Right", "RS Up", "RS Down", 0.5))
		var pos_topleft:Vector2 = KingFace.MoyaPosition + BOUNDS/2
		
		if king_input.length() > 0:
			king_vector = king_input.normalized()
			KingFace.MoyaPosition = Vector2(clampf(pos_topleft.x + (delta * king_vector.x * SPEED), 0, BOUNDS.x) - BOUNDS.x/2,
											clampf(pos_topleft.y + (delta * king_vector.y * SPEED), 0, BOUNDS.y) - BOUNDS.y/2)
		else:
			var pos_new:Vector2 = pos_topleft + (king_vector * delta * SPEED)
			var pos_bounced:Vector2 = Vector2(pingpong(pos_new.x, BOUNDS.x), pingpong(pos_new.y, BOUNDS.y))
			var vec_bounce:Vector2 = Vector2(int(pos_new.x != pos_bounced.x), int(pos_new.y != pos_bounced.y)) * -2 + Vector2.ONE
			KingFace.MoyaPosition = pos_bounced - BOUNDS/2
			king_vector *= vec_bounce
		
		#TODO: make him say words here
		if text_input.length() > 0:
			text_vector = text_input.normalized()
