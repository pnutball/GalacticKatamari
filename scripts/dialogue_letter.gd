extends Label
var delay:float = 0
var effect:StringName = &""
var face:StringName = &"Neutral"
var shocked:bool = false
@export var effectMult:float = 0
@onready var base_position:Vector2 = position
var elapsed:float = 0
func _ready():
	await get_tree().create_timer(delay).timeout
	show_letter()

func _process(delta):
	elapsed += delta
	match effect:
		&"vwave": position = base_position + Vector2(0, sin((elapsed + delay) * 6) * 8 * effectMult)
		&"hwave": position = base_position + Vector2(sin((elapsed + delay) * 6) * 8 * effectMult, 0)
		&"rainbow": self_modulate = Color.from_hsv(fposmod((delay - elapsed) * -0.5, 1), 0.5, 1)

func show_letter():
	KingFace.Emotion = face
	KingFace.Shocked = shocked
	$FadeAnim.play("FadeIn")
