extends Label

var delay:float = 0
var effect:StringName = &""
var face:StringName = &"Neutral"
var goal:StringName = &""
var shocked:bool = false
var last_letter:bool = false
var anim_finished:bool = false

signal last_letter_shown

@export var effectMult:float = 0
@onready var base_position:Vector2 = position
@onready var base_color:Color = self_modulate

var elapsed:float = 0

func _ready():
	await get_tree().create_timer(delay, false).timeout
	if not anim_finished: show_letter()

func _process(delta):
	elapsed += delta
	match effect:
		&"vwave": position = base_position + Vector2(0, sin((elapsed + delay) * 6) * 8 * effectMult)
		&"jitter": position = base_position + Vector2(0, (roundf(sin((elapsed + delay) * 24) * 0.5 + 0.5) * 8 - 4) * effectMult)
		&"hwave": position = base_position + Vector2(sin((elapsed + delay) * 6) * 8 * effectMult, 0)
		&"rainbow": self_modulate = Color.from_hsv(fposmod((delay - elapsed) * -0.5, 1), 0.5, 1)
		&"pulse": self_modulate = base_color * Color(1, 1, 1, (sin((elapsed + delay) * 6) + 1) * 0.4 + 0.2)

func show_letter():
	KingFace.Emotion = face
	KingFace.Shocked = shocked
	$FadeAnim.play("FadeIn")
	await $FadeAnim.animation_finished
	anim_finished = true

func skip():
	if not anim_finished:
		anim_finished = true
		$FadeAnim.play("FadeIn", -1, INF)
		if last_letter:
			KingFace.Emotion = face
			KingFace.Shocked = shocked

func conditional_end_talk(): 
	if goal == &"size": 
		KingFace.get_node("GoalHandAnimation").play("in")
	if goal == &"time":
		KingFace.get_node("TimeHandAnimation").play("in")
	if last_letter: 
		KingFace.Talking = false
		last_letter_shown.emit()
