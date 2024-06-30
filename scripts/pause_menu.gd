extends Control

func _ready():
	$PauseBG/TestKey1.texture = GKGlobal.get_key(KEY_W, false)
	$PauseBG/TestKey2.texture = GKGlobal.get_key(KEY_L, true)
	$PauseBG/TestKey3.texture = GKGlobal.get_key(KEY_ASCIICIRCUM, false)
	
	$"PauseBG/GridContainer/TestBtnGenA".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_GENERIC)
	$"PauseBG/GridContainer/TestBtnGenRB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_GENERIC)
	$"PauseBG/GridContainer/TestBtnGenRT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_GENERIC)
	$"PauseBG/GridContainer/TestBtnGenRS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_GENERIC)
	$"PauseBG/GridContainer/TestBtnGenStart".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_GENERIC)
	$"PauseBG/GridContainer/TestBtnXboxA".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_XBOX)
	$"PauseBG/GridContainer/TestBtnXboxRB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_XBOX)
	$"PauseBG/GridContainer/TestBtnXboxRT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_XBOX)
	$"PauseBG/GridContainer/TestBtnXboxRS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_XBOX)
	$"PauseBG/GridContainer/TestBtnXboxStart".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_XBOX)
	$"PauseBG/GridContainer/TestBtn360A".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_XBOX_360)
	$"PauseBG/GridContainer/TestBtn360RB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_XBOX_360)
	$"PauseBG/GridContainer/TestBtn360RT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_XBOX_360)
	$"PauseBG/GridContainer/TestBtn360RS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_XBOX_360)
	$"PauseBG/GridContainer/TestBtn360Start".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_XBOX_360)
	$"PauseBG/GridContainer/TestBtnPSA".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_PLAYSTATION)
	$"PauseBG/GridContainer/TestBtnPSRB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_PLAYSTATION)
	$"PauseBG/GridContainer/TestBtnPSRT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_PLAYSTATION)
	$"PauseBG/GridContainer/TestBtnPSRS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_PLAYSTATION)
	$"PauseBG/GridContainer/TestBtnPSStart".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_PLAYSTATION)
	$"PauseBG/GridContainer/TestBtnPS3A".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_PLAYSTATION_3)
	$"PauseBG/GridContainer/TestBtnPS3RB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_PLAYSTATION_3)
	$"PauseBG/GridContainer/TestBtnPS3RT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_PLAYSTATION_3)
	$"PauseBG/GridContainer/TestBtnPS3RS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_PLAYSTATION_3)
	$"PauseBG/GridContainer/TestBtnPS3Start".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_PLAYSTATION_3)
	$"PauseBG/GridContainer/TestBtnNintendoA".texture = GKGlobal.get_button(GKGlobal.BUTTON_A, false, GKGlobal.BRAND_NINTENDO)
	$"PauseBG/GridContainer/TestBtnNintendoRB".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_SHOULDER, false, GKGlobal.BRAND_NINTENDO)
	$"PauseBG/GridContainer/TestBtnNintendoRT".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_TRIGGER, false, GKGlobal.BRAND_NINTENDO)
	$"PauseBG/GridContainer/TestBtnNintendoRS".texture = GKGlobal.get_button(GKGlobal.BUTTON_RIGHT_STICK, false, GKGlobal.BRAND_NINTENDO)
	$"PauseBG/GridContainer/TestBtnNintendoStart".texture = GKGlobal.get_button(GKGlobal.BUTTON_START, false, GKGlobal.BRAND_NINTENDO)
	
	$"PauseBG/TestStickL".texture = GKGlobal.get_stick(false, Vector2(0,1), GKGlobal.BRAND_GENERIC)
	$"PauseBG/TestStickR".texture = GKGlobal.get_stick(true, Vector2(-1,-1), GKGlobal.BRAND_GENERIC)
	$"PauseBG/TestStickR2".texture = GKGlobal.get_stick(true, Vector2.ZERO, GKGlobal.BRAND_GENERIC)

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		$PauseBG.visible = not get_tree().paused
		get_tree().paused = not get_tree().paused
		if has_node("../Debug"): $"../Debug".visible = not get_tree().paused
		if has_node("../TimerNormal"): $"../TimerNormal".visible = not get_tree().paused
		if has_node("../TimerTT"): $"../TimerTT".visible = not get_tree().paused
		$"../SizeMeter".visible = not get_tree().paused
		$"../ObjectIndicator".visible = not get_tree().paused
		DialogueBox.visible = not get_tree().paused
		KingFace.visible = not get_tree().paused
		if get_tree().paused: $PauseSound.play()
