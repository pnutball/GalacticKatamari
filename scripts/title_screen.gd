extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Ouji/OujiAnimation.play("Ouji_Idle")
	$"FadeOverlay/FadeOverlayAnim".play("FadeIn")
	await $"FadeOverlay/FadeOverlayAnim".animation_finished
	$TitleMusic.play()
	$TitleLogo/LogoAnimation.play("ShowLogo")
	await $TitleLogo/LogoAnimation.animation_finished
	$StartText.visible = true
	$"StartText/StartFadeAnim".play("FadeInOut")
	

func _input(_event):
	if Input.is_action_just_pressed("Confirm") and $StartText.visible:
		$StartText.visible = false
		$ConfirmSound.play()
		$"FadeOverlay/FadeOverlayAnim".play("FadeOut")
		await $"FadeOverlay/FadeOverlayAnim".animation_finished
		get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")
