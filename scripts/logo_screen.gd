extends Control

func _ready():
	# The Prince fly down animation a-la BK goes here at some point
	# TODO: Add ability to skip by pressing A/Cross/Start/Enter/Space
	$LogoAnimation.animation_set_next(&"DevBy", &"PowBy")
	$LogoAnimation.animation_set_next(&"PowBy", &"Fade")
	$LogoAnimation.animation_set_next(&"Fade", &"LoadMenu")
	$LogoAnimation.play(&"DevBy")

func LogosDone():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
