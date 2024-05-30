extends Label
var delay:float = 0
var effect:StringName = &""
@export var effectMult:float = 0
@onready var base_position:Vector2 = position
var elapsed:float = 0
func _ready():
	await get_tree().create_timer(delay).timeout
	$FadeAnim.play("FadeIn")

func _process(delta):
	elapsed += delta
	match effect:
		&"vwave": position = base_position + Vector2(0, sin((elapsed + delay) * 6) * 8 * effectMult)
