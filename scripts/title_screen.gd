extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Ouji/OujiAnimation.play("Ouji_Idle")
	$Title/FadeOverlay/FadeOverlayAnim.play("FadeIn")
	await $Title/FadeOverlay/FadeOverlayAnim.animation_finished
	$TitleMusic.play()
	$Title/CopyrightText/CopyrightFade.play("fade_in")
	$Title/TitleLogo/LogoAnimation.play("ShowLogo")
	await $Title/TitleLogo/LogoAnimation.animation_finished
	$Title/StartText.visible = true
	$Title/StartText/StartFadeAnim.play("FadeInOut")
	

func _input(_event):
	if Input.is_action_just_pressed("Confirm") and $Controls.visible:
		pass
	elif Input.is_action_just_pressed("Confirm") and has_node("Title/StartText") and $Title/StartText.visible:
		$Title/StartText.visible = false
		$ConfirmSound.play()
		if not GKGlobal.is_demo:
			$Title/FadeOverlay/FadeOverlayAnim.play("FadeOut")
			await $Title/FadeOverlay/FadeOverlayAnim.animation_finished
			get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")
		else:
			$Title/CopyrightText/CopyrightFade.play("fade_out")
			$Title/TitleLogo/LogoAnimation.play("HideLogo")
			await $Title/TitleLogo/LogoAnimation.animation_finished
			$Title.queue_free()
			$Controls/ControlsFadeAnim.play("fade_in")
