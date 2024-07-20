extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	_refresh_images()
	GKGlobal.controller_changed.connect(func(index:int): if index == 0: _refresh_images())
	$Ouji/OujiAnimation.play("Ouji_Idle")
	$Title/FadeOverlay/FadeOverlayAnim.play("FadeIn")
	await $Title/FadeOverlay/FadeOverlayAnim.animation_finished
	$TitleMusic.play()
	$Title/CopyrightText/CopyrightFade.play("fade_in")
	$Title/TitleLogo/LogoAnimation.play("ShowLogo")
	await $Title/TitleLogo/LogoAnimation.animation_finished
	$Title/Start.visible = true
	$Title/Start/StartFadeAnim.play("FadeInOut")

var start_key:Texture2D = GKGlobal.get_key(KEY_ENTER)
var start_button:Texture2D

func _process(_delta):
	if has_node("Title/Start/StartImg"):
		$Title/Start/StartImg.texture = start_button if GKGlobal.usingController else start_key

func _refresh_images():
	start_button = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.get_brand())

func _input(_event):
	if Input.is_action_just_pressed("Confirm") and $Controls.visible:
		$Controls/ControlsFadeAnim.play("fade_out")
		await $Controls/ControlsFadeAnim.animation_finished
	elif (Input.is_action_just_pressed("Confirm") or Input.is_action_just_pressed("Pause")) and has_node("Title/Start") and $Title/Start.visible:
		$Title/Start.visible = false
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
