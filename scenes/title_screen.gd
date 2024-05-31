extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$TitleMusic.play()
	$"Start/Fade In _ Out".play("fade in and out")
	$"Fade Out/Animation".play("fade out")
	$Ouji/OujiAnimation2.play("Ouji_Idle")

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		$Start.visible = false
		$Start/Confirm.play()
		$"Fade Out/Animation".play("fade in")
		for i in 60:
			$TitleMusic.volume_db -= 1
			await get_tree().create_timer(0.016).timeout
		get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")
