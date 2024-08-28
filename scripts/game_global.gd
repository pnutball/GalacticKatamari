extends Node

func _init(): process_mode = Node.PROCESS_MODE_ALWAYS

func _ready(): RenderingServer.set_default_clear_color(Color.BLACK)

const is_demo:bool = preload("res://flags.json").data.demo

const ANGLE_SNAP_CURVE:Curve = preload("res://data/input_angle_curve.tres")

## An array of info for each Ouji ID.
##
## "FormalName": The formal name of the cousin, used outside dialogue.
## "DialogueName": The name of the cousin, used inside dialogue.
## "DialogueColor": The color of the cousin's dialogue name, as an Array[Color].
## If the DialogueColor array is shorter than the DialogueName, the array will loop.
## "DialogueEffect": The effect of the cousin's dialogue name, as a StringName.
## "Model": The cousin's rigged model.
## "ShortSound": The cousin's short sound effect.
## "LongSound": The cousin's long sound effect.
const OujiInfo:Array[Dictionary] = [
	{
		"FormalName":"???",
		"DialogueName":"???",
		"DialogueColor":[Color("#CCC")],
		"DialogueEffect":&"",
		"Model": "res://assets/ouji/rig/Ouji01.tscn",
		"ShortSound": null,
		"LongSound": null
	}, # Fallback/error cousin
	{
		"FormalName":"The Prince",
		"DialogueName":"Prince",
		"DialogueColor":[Color("#8FC93A")],
		"DialogueEffect":&"",
		"Model": "res://assets/ouji/rig/Ouji01.tscn",
		"ShortSound": null,
		"LongSound": null
	} # OUJI01, The Prince
]

var MusicList:Dictionary = preload("res://data/music.json").data["music"]

var selectedMusic = ""

## Returns the song's AudioStream and its localized name.
func get_music(id:String) -> Array:
	var stream:AudioStream = AudioStream.new() if not MusicList.has(id) else load(MusicList[id].path)
	var song_name:String = "" if not MusicList.has(id) else get_localized_string(MusicList[id].name)
	return [stream, song_name]

const RANK_IMAGES:Array[Texture2D] = [
	preload("res://assets/textures/ui/rank_1st.png"),
	preload("res://assets/textures/ui/rank_2nd.png"),
	preload("res://assets/textures/ui/rank_3rd.png"),
	preload("res://assets/textures/ui/rank_blank.png")
]

func calculate_rank_percentage(names:Array[String], counts:Array[int]) -> Array[Array]:
	var combo:Array[Array] = []
	for index in names.size():
		combo.push_back([names[index],counts[index]])
	combo.sort_custom(func(a,b): return a[1] > b[1])
	
	var rank:Array[Array] = []
	rank.resize(3)
	rank.fill([3, "--------------------"])
	if not names.is_empty():
		var total:int = counts.reduce(func(accum, number): return accum + number)
		for index in mini(combo.size(), 3):
			var rank_entry = [0]
			if index > 0:
				rank_entry[0] = rank[index - 1][0]
				if combo[index - 1][1] != combo[index][1]: rank_entry[0] += 1
			rank_entry.push_back("%d%% %s"%[int(combo[index][1] * 100 / total), get_localized_string(preload("res://data/collection.json").data.collection.get(combo[index][0], {}).get("name", {}))])
			rank[index] = rank_entry
	return rank

var resultsKatamariImage:Image
var resultsKatamariScale:float

func create_result_katamari_image(source_image:Image) -> void:
	var usedRect: Rect2i = source_image.get_used_rect()
	var squarewidth:int = max(usedRect.size.x, usedRect.size.y)
	var squared := Image.create(squarewidth, squarewidth, false, source_image.get_format())
	squared.blend_rect(source_image, usedRect, (Vector2i(squarewidth,squarewidth)-usedRect.size)/2)
	print(squared.get_size())
	squared.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	print(squared.get_size())
	resultsKatamariImage = squared

var players:Array[Array] = [
	[01, "Player 1"]
]

var collectedObjects:Array[StringName] = []

var lastWindowMode:int = Window.MODE_WINDOWED

signal controller_changed(index:int)
@onready var _controller_list:Array[String] = [
	Input.get_joy_name(0),
	Input.get_joy_name(1),
	Input.get_joy_name(2),
	Input.get_joy_name(3)
]

func _process(_delta):
	for i in _controller_list.size():
		if _controller_list[i] != Input.get_joy_name(i):
			_controller_list[i] = Input.get_joy_name(i)
			controller_changed.emit(i)

var usingController:bool = false:
	get:
		return usingController
	set(new):
		var old = usingController
		usingController = new
		if old != new:
			controller_changed.emit(0)

const _KEY_IMG:Image = preload("res://assets/textures/input/key_symbols.png")
const _KEY_IMG_SIZE:Vector2i = Vector2i(52,26)
const _KEY_IMG_MAP:Dictionary = {
	KEY_ESCAPE: Vector2i(0, 0),
	KEY_TAB: Vector2i(52, 0),
	KEY_BACKSPACE: Vector2i(104, 0),
	KEY_ENTER: Vector2i(156, 0),
	KEY_INSERT: Vector2i(208, 0),
	KEY_DELETE: Vector2i(260, 0),
	KEY_PAUSE: Vector2i(312, 0),
	KEY_HOME: Vector2i(364, 0),
	KEY_END: Vector2i(0, 26),
	KEY_SHIFT: Vector2i(52, 26),
	KEY_A: Vector2i(104, 26),
	KEY_B: Vector2i(156, 26),
	KEY_C: Vector2i(208, 26),
	KEY_D: Vector2i(260, 26),
	KEY_E: Vector2i(312, 26),
	KEY_F: Vector2i(364, 26),
	KEY_G: Vector2i(0, 52),
	KEY_H: Vector2i(52, 52),
	KEY_I: Vector2i(104, 52),
	KEY_J: Vector2i(156, 52),
	KEY_K: Vector2i(208, 52),
	KEY_L: Vector2i(260, 52),
	KEY_M: Vector2i(312, 52),
	KEY_N: Vector2i(364, 52),
	KEY_O: Vector2i(0, 78),
	KEY_P: Vector2i(52, 78),
	KEY_Q: Vector2i(104, 78),
	KEY_R: Vector2i(156, 78),
	KEY_S: Vector2i(208, 78),
	KEY_T: Vector2i(260, 78),
	KEY_U: Vector2i(312, 78),
	KEY_V: Vector2i(364, 78),
	KEY_W: Vector2i(0, 104),
	KEY_X: Vector2i(52, 104),
	KEY_Y: Vector2i(104, 104),
	KEY_Z: Vector2i(156, 104),
	KEY_1: Vector2i(208, 104),
	KEY_2: Vector2i(260, 104),
	KEY_3: Vector2i(312, 104),
	KEY_4: Vector2i(364, 104),
	KEY_5: Vector2i(0, 130),
	KEY_6: Vector2i(52, 130),
	KEY_7: Vector2i(104, 130),
	KEY_8: Vector2i(156, 130),
	KEY_9: Vector2i(208, 130),
	KEY_0: Vector2i(260, 130),
	KEY_MINUS: Vector2i(312, 130),
	KEY_EQUAL: Vector2i(364, 130),
	KEY_BRACKETLEFT: Vector2i(0, 156),
	KEY_BRACKETRIGHT: Vector2i(52, 156),
	KEY_BACKSLASH: Vector2i(104, 156),
	KEY_SEMICOLON: Vector2i(156, 156),
	KEY_APOSTROPHE: Vector2i(208, 156),
	KEY_COMMA: Vector2i(260, 156),
	KEY_PERIOD: Vector2i(312, 156),
	KEY_SLASH: Vector2i(364, 156),
	KEY_F1: Vector2i(0, 182),
	KEY_F2: Vector2i(52, 182),
	KEY_F3: Vector2i(104, 182),
	KEY_F4: Vector2i(156, 182),
	KEY_F5: Vector2i(208, 182),
	KEY_F6: Vector2i(260, 182),
	KEY_F7: Vector2i(312, 182),
	KEY_F8: Vector2i(364, 182),
	KEY_F9: Vector2i(0, 208),
	KEY_F10: Vector2i(52, 208),
	KEY_F11: Vector2i(104, 208),
	KEY_F12: Vector2i(156, 208),
	KEY_KP_MULTIPLY: Vector2i(208, 208),
	KEY_KP_DIVIDE: Vector2i(260, 208),
	KEY_KP_ADD: Vector2i(312, 208),
	KEY_KP_SUBTRACT: Vector2i(364, 208),
	KEY_KP_1: Vector2i(0, 234),
	KEY_KP_2: Vector2i(52, 234),
	KEY_KP_3: Vector2i(104, 234),
	KEY_KP_4: Vector2i(156, 234),
	KEY_KP_5: Vector2i(208, 234),
	KEY_KP_6: Vector2i(260, 234),
	KEY_KP_7: Vector2i(312, 234),
	KEY_KP_8: Vector2i(364, 234),
	KEY_KP_9: Vector2i(0, 260),
	KEY_KP_0: Vector2i(52, 260),
	KEY_KP_PERIOD: Vector2i(104, 260),
	KEY_KP_ENTER: Vector2i(156, 260),
	KEY_SPACE: Vector2i(208, 260),
	KEY_QUOTELEFT: Vector2i(260, 260),
	KEY_CTRL: Vector2i(312, 260),
	KEY_ALT: Vector2i(364, 260)
}

func is_key_valid(key:Key) -> bool:
	return _KEY_IMG_MAP.has(key)

func get_key(key:Key, pressed:bool = false) -> ImageTexture:
	var key_image:Image = Image.create(68, 68, false, Image.FORMAT_RGBA8)
	key_image.blend_rect(
		preload("res://assets/textures/input/input_bg_key_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_key.png"),
		Rect2i(Vector2i.ZERO, Vector2i(68,68)),
		Vector2i.ZERO
	)
	if is_key_valid(key):
		key_image.blend_rect(_KEY_IMG, Rect2i(_KEY_IMG_MAP[key], _KEY_IMG_SIZE), Vector2i(8,21))
	#else: push_warning("Invalid key \"" + OS.get_keycode_string(key) + "\", resulting keycap texture has no label.")
	key_image.fix_alpha_edges()
	return ImageTexture.create_from_image(key_image)

#region ControllerButton enum
enum ControllerButton {BUTTON_NONE = -1, BUTTON_GUIDE=0, BUTTON_A=1, BUTTON_B=2, BUTTON_X=3, BUTTON_Y=4, BUTTON_START=5, BUTTON_BACK=6, BUTTON_LEFT_SHOULDER=7, BUTTON_RIGHT_SHOULDER=8, BUTTON_LEFT_TRIGGER=9, BUTTON_RIGHT_TRIGGER=10, BUTTON_LEFT_STICK=11, BUTTON_RIGHT_STICK=12}
const BUTTON_NONE:ControllerButton = ControllerButton.BUTTON_NONE
const BUTTON_GUIDE:ControllerButton = ControllerButton.BUTTON_GUIDE
const BUTTON_A:ControllerButton = ControllerButton.BUTTON_A
const BUTTON_B:ControllerButton = ControllerButton.BUTTON_B
const BUTTON_X:ControllerButton = ControllerButton.BUTTON_X
const BUTTON_Y:ControllerButton = ControllerButton.BUTTON_Y
const BUTTON_START:ControllerButton = ControllerButton.BUTTON_START
const BUTTON_BACK:ControllerButton = ControllerButton.BUTTON_BACK
const BUTTON_LEFT_SHOULDER:ControllerButton = ControllerButton.BUTTON_LEFT_SHOULDER
const BUTTON_RIGHT_SHOULDER:ControllerButton = ControllerButton.BUTTON_RIGHT_SHOULDER
const BUTTON_LEFT_TRIGGER:ControllerButton = ControllerButton.BUTTON_LEFT_TRIGGER
const BUTTON_RIGHT_TRIGGER:ControllerButton = ControllerButton.BUTTON_RIGHT_TRIGGER
const BUTTON_LEFT_STICK:ControllerButton = ControllerButton.BUTTON_LEFT_STICK
const BUTTON_RIGHT_STICK:ControllerButton = ControllerButton.BUTTON_RIGHT_STICK
#endregion
#region Brand enum
enum Brand {BRAND_GENERIC = 0, BRAND_XBOX = 1, BRAND_XBOX_360 = 2, BRAND_PLAYSTATION = 3, BRAND_PLAYSTATION_3 = 4, BRAND_NINTENDO = 5}
const BRAND_GENERIC:Brand = Brand.BRAND_GENERIC
const BRAND_XBOX:Brand = Brand.BRAND_XBOX
const BRAND_XBOX_360:Brand = Brand.BRAND_XBOX_360
const BRAND_PLAYSTATION:Brand = Brand.BRAND_PLAYSTATION
const BRAND_PLAYSTATION_3:Brand = Brand.BRAND_PLAYSTATION_3
const BRAND_NINTENDO:Brand = Brand.BRAND_NINTENDO
#endregion
const _BUTTON_IMG:Image = preload("res://assets/textures/input/button_symbols.png")
const _BUTTON_IMG_SIZE:Vector2i = Vector2i(52,26)
const _BUTTON_IMG_MAP:Dictionary = {
	BUTTON_NONE: Vector2i.ZERO,
	BUTTON_GUIDE: Vector2i.ZERO,
	BUTTON_A: Vector2i(52, 0),
	BUTTON_B: Vector2i(52, 26),
	BUTTON_X: Vector2i(104, 0),
	BUTTON_Y: Vector2i(104, 26),
	BUTTON_START: Vector2i(156, 0),
	BUTTON_BACK: Vector2i(156, 26),
	BUTTON_LEFT_SHOULDER: Vector2i(260, 0),
	BUTTON_RIGHT_SHOULDER: Vector2i(260, 26),
	BUTTON_LEFT_TRIGGER: Vector2i(312, 0),
	BUTTON_RIGHT_TRIGGER: Vector2i(312, 26),
	BUTTON_LEFT_STICK: Vector2i(364, 0),
	BUTTON_RIGHT_STICK: Vector2i(364, 26)
}

func get_button(button:ControllerButton, pressed:bool = false, brand:Brand = BRAND_GENERIC) -> ImageTexture:
	var key_image:Image = Image.create(68, 68, false, Image.FORMAT_RGBA8)
	var bg_image:Image
	var label_offset:Vector2i = Vector2i(8,21)
	match button:
		BUTTON_LEFT_SHOULDER: 
			bg_image = preload("res://assets/textures/input/input_bg_bumper_L_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_bumper_L.png")
			label_offset = Vector2i(12,21)
		BUTTON_RIGHT_SHOULDER: 
			bg_image = preload("res://assets/textures/input/input_bg_bumper_R.png") if pressed else preload("res://assets/textures/input/input_bg_bumper_R_pressed.png")
			label_offset = Vector2i(4,21)
		BUTTON_LEFT_TRIGGER: 
			if brand == BRAND_XBOX_360:
				bg_image = preload("res://assets/textures/input/input_bg_key_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_key.png")
			else: bg_image = preload("res://assets/textures/input/input_bg_trigger_L_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_trigger_L.png")
		BUTTON_RIGHT_TRIGGER: 
			if brand == BRAND_XBOX_360:
				bg_image = preload("res://assets/textures/input/input_bg_key_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_key.png")
			else: bg_image = preload("res://assets/textures/input/input_bg_trigger_R_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_trigger_R.png")
		BUTTON_LEFT_STICK: 
			bg_image = preload("res://assets/textures/input/input_bg_stickbutton_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_stickbutton.png")
			label_offset = Vector2i(8,2)
		BUTTON_RIGHT_STICK: 
			bg_image = preload("res://assets/textures/input/input_bg_stickbutton_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_stickbutton.png")
			label_offset = Vector2i(8,2)
		_: bg_image = preload("res://assets/textures/input/input_bg_facebutton_pressed.png") if pressed else preload("res://assets/textures/input/input_bg_facebutton.png")
	key_image.blend_rect(bg_image, Rect2i(Vector2i.ZERO, Vector2i(68,68)), Vector2i.ZERO)
	
	var button_position:Vector2i = _BUTTON_IMG_MAP[button]
	if brand == BRAND_XBOX or brand == BRAND_XBOX_360: button_position += Vector2i(0, 52)
	elif brand == BRAND_PLAYSTATION or brand == BRAND_PLAYSTATION_3: button_position += Vector2i(0, 104)
	elif brand == BRAND_NINTENDO: button_position += Vector2i(0, 156)
	
	if brand == BRAND_XBOX_360 and button == BUTTON_BACK: button_position = Vector2i(156,26)
	if brand == BRAND_XBOX_360 and button == BUTTON_START: button_position = Vector2i(156,0)
	if brand == BRAND_PLAYSTATION_3 and button == BUTTON_BACK: button_position = Vector2i(0,78)
	if brand == BRAND_PLAYSTATION_3 and button == BUTTON_START: button_position = Vector2i(156,0)
	
	key_image.blend_rect(_BUTTON_IMG, Rect2i(button_position, _BUTTON_IMG_SIZE), label_offset)
	key_image.fix_alpha_edges()
	return ImageTexture.create_from_image(key_image)

func get_stick(right:bool, direction:Vector2, brand:Brand = BRAND_GENERIC) -> ImageTexture:
	var stick_image:Image = Image.create(68, 68, false, Image.FORMAT_RGBA8)
	stick_image.blend_rect(preload("res://assets/textures/input/input_bg_stick_base.png"), Rect2i(Vector2i.ZERO, Vector2i(68,68)), Vector2i.ZERO)
	var button_position:Vector2i = Vector2i(208, int(right) * 26)
	if brand == BRAND_XBOX or brand == BRAND_XBOX_360: button_position += Vector2i(0, 52)
	elif brand == BRAND_PLAYSTATION or brand == BRAND_PLAYSTATION_3: button_position += Vector2i(0, 104)
	elif brand == BRAND_NINTENDO: button_position += Vector2i(0, 156)
	var stick_position:Vector2i = Vector2i(((direction.limit_length() * Vector2(1, -1)).normalized() * 11).round())
	stick_image.blend_rect(preload("res://assets/textures/input/input_bg_stick_cap.png"), Rect2i(Vector2i.ZERO, Vector2i(68,68)), stick_position)
	stick_image.blend_rect(_BUTTON_IMG, Rect2i(button_position, _BUTTON_IMG_SIZE), Vector2i(8,21) + stick_position)
	stick_image.fix_alpha_edges()
	return ImageTexture.create_from_image(stick_image)

func get_brand(device:int = 0) -> Brand:
	var device_name:String = Input.get_joy_name(device)
	if device_name.contains("Xbox") and not device_name.contains("Xbox 360"):
		return BRAND_XBOX
	elif device_name.contains("Xbox 360"):
		return BRAND_XBOX_360
	elif (
		device_name.contains("PlayStation") or
		device_name.contains("PS") or
		device_name.contains("DualShock")
	) and not (
		device_name.contains("PlayStation 2") or
		device_name.contains("PlayStation 3") or
		device_name.contains("PlayStation Portable") or 
		device_name.contains("Vita") or 
		device_name.contains("PS1") or
		device_name.contains("PS2") or
		device_name.contains("PS3") or
		device_name.contains("PSP") or
		device_name.contains("DualShock 2") or
		device_name.contains("DualShock 3") or 
		device_name.contains("Ramox FPS")
	):
		return BRAND_PLAYSTATION
	elif (
		device_name.contains("PlayStation 2") or
		device_name.contains("PlayStation 3") or
		device_name.contains("PlayStation Portable") or 
		device_name.contains("Vita") or 
		device_name.contains("PS1") or
		device_name.contains("PS2") or
		device_name.contains("PS3") or
		device_name.contains("PSP") or
		device_name.contains("DualShock 2") or
		device_name.contains("DualShock 3")
	) and not device_name.contains("Ramox FPS"):
		return BRAND_PLAYSTATION_3
	elif (
		device_name.contains("Nintendo") or 
		device_name.contains("Wii U") or 
		device_name.contains("8BitDo Ultimate") or 
		device_name.contains("8BitDo Pro")
	):
		return BRAND_NINTENDO
	else:
		return BRAND_GENERIC

func get_controller_texture(device:int = 0) -> Texture2D:
	var brand = get_brand(device)
	if device == 0 and not usingController:
		return preload("res://assets/textures/input/controller_keyboard.png")
	elif brand == BRAND_PLAYSTATION:
		return preload("res://assets/textures/input/controller_playstation.png")
	elif brand == BRAND_PLAYSTATION_3:
		return preload("res://assets/textures/input/controller_playstation_3.png")
	elif brand == BRAND_XBOX:
		return preload("res://assets/textures/input/controller_xbox.png")
	elif brand == BRAND_XBOX_360:
		return preload("res://assets/textures/input/controller_xbox_360.png")
	elif Input.get_joy_name(device).contains("Wii U"):
		return preload("res://assets/textures/input/controller_wii_u.png")
	elif brand == BRAND_NINTENDO:
		return preload("res://assets/textures/input/controller_nintendo.png")
	else:
		return preload("res://assets/textures/input/controller_generic.png")

func _input(event):
	if (event is InputEventKey or event is InputEventMouseButton):
		usingController = false
	elif (event is InputEventJoypadButton) and event.device == 0:
		usingController = true
	if Input.is_action_just_pressed("Fullscreen"):
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			@warning_ignore("int_as_enum_without_cast")
			get_window().mode = lastWindowMode
		else: 
			lastWindowMode = get_window().mode
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	if Input.is_key_pressed(KEY_F9): get_tree().change_scene_to_file("res://scenes/debug_menu.tscn")

func snap_input_angle(input:Vector2) -> Vector2:
	return (Vector2.RIGHT * input.length()).rotated(
		ANGLE_SNAP_CURVE.sample((input.angle() / TAU) + 0.5) * PI
	)

## Gets a localized string from a dictionary of translations.
func get_localized_string(input:Dictionary) -> String:
	return input.get(TranslationServer.get_locale().get_slice("_", 0), input.get("en", "MISSING STRING!"))

func get_localized_plural(count:int, input:Dictionary) -> String:
	var plurals:Array = input.get(TranslationServer.get_locale().get_slice("_", 0), input.get("en", ["MISSING STRING!"]))
	return plurals[min(count, max(0, plurals.size() - 1), )]
