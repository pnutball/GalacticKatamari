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

func _input(_event):
	if Input.is_action_just_pressed("Confirm") and ($LogoAnimation.current_animation == &"DevBy" or $LogoAnimation.current_animation == &"PowBy"):
		$LogoAnimation.play($LogoAnimation.animation_get_next($LogoAnimation.current_animation))
