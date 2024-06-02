extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Swirls/AnimationPlayer.play("Swirl")
	$Music.play()
