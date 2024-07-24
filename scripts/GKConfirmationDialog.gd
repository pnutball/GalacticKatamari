@tool
class_name GKConfirmationDialog
extends ConfirmationDialog

## If true, highlights the (first) cancel button when the dialog is made visible.
@export var highlight_cancel:bool = false

var can_play_sound:bool = false

func _init():
	visibility_changed.connect(_visibility_changed)

func _ready():
	if not Engine.is_editor_hint():
		var confirm_sound:AudioStreamPlayer = AudioStreamPlayer.new()
		confirm_sound.name = &"SoundConfirm"
		confirm_sound.bus = &"SFX"
		confirm_sound.stream = preload("res://assets/sounds/ui/confirm.wav")
		add_child(confirm_sound, false, Node.INTERNAL_MODE_BACK)
		var cancel_sound:AudioStreamPlayer = AudioStreamPlayer.new()
		cancel_sound.name = &"SoundCancel"
		cancel_sound.bus = &"SFX"
		cancel_sound.stream = preload("res://assets/sounds/ui/cancel.wav")
		add_child(cancel_sound, false, Node.INTERNAL_MODE_BACK)
		var select_sound:AudioStreamPlayer = AudioStreamPlayer.new()
		select_sound.name = &"SoundSelect"
		select_sound.bus = &"SFX"
		select_sound.stream = preload("res://assets/sounds/ui/select.wav")
		add_child(select_sound, false, Node.INTERNAL_MODE_BACK)
	for node in get_children(true):
		if node is Label:
			node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if node is HBoxContainer:
			for child in node.get_children(true):
				if child is Button:
					child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					child.size_flags_vertical = Control.SIZE_FILL
					child.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
					child.mouse_entered.connect(child.grab_focus)
					if not Engine.is_editor_hint():
						child.focus_entered.connect(conditional_play_sound.bind(_SOUNDS.SELECT))
						if child == get_cancel_button(): child.pressed.connect(conditional_play_sound.bind(_SOUNDS.CANCEL))
						else: child.pressed.connect(conditional_play_sound.bind(_SOUNDS.CONFIRM))
				elif child is Control:
					child.custom_minimum_size = Vector2(16,0)
					child.size_flags_horizontal = Control.SIZE_FILL
					child.size_flags_vertical = Control.SIZE_FILL

func _process(_delta):
	if visible and not Engine.is_editor_hint():
		var base_size:Vector2 = get_parent().get_viewport().size
		var scaled_size:Vector2 = base_size * (1080 / base_size.y)
		position = (Vector2i(scaled_size) - size) / 2

func _visibility_changed():
	can_play_sound = false
	if highlight_cancel: get_cancel_button().grab_focus()
	await get_tree().process_frame
	can_play_sound = visible

enum _SOUNDS {CONFIRM, CANCEL, SELECT}
func conditional_play_sound(sound:_SOUNDS):
	if not Engine.is_editor_hint():
		match sound:
			_SOUNDS.CONFIRM: $SoundConfirm.play()
			_SOUNDS.CANCEL: $SoundCancel.play()
			_SOUNDS.SELECT: if can_play_sound: $SoundSelect.play()

func _input(_event):
	if not Engine.is_editor_hint() and visible and Input.is_action_just_pressed("Cancel"):
		conditional_play_sound(_SOUNDS.CANCEL)
		visible = false
		canceled.emit()
