extends Label
var delay:float = 0
func _ready():
	await get_tree().create_timer(delay).timeout
	$AnimationPlayer.play("FadeIn")
