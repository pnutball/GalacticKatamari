@icon("res://editor/class_icons/GKEditorPropertyDialogue.svg")
class_name GKEditorPropertyDialogue
extends GKEditorPropertyLocalized

func _init():
	property_type = "Dialogue"
	vertical = true

func _ready():
	super()
	var new_button:Button = Button.new()
	new_button.icon = preload("res://editor/icons/info.png")
	#region Tooltip
	new_button.tooltip_text = """Format code reference:

Use Enter or \\n to add a line break.
End each box with |break|

|color:#HEXCLR| - Change text color
|bgcolor:#HEXCLR| - Change bubble color
|hwave| - Wave text horizontally
|vwave| - Wave text vertically
|jitter| - Jitters text vertically (like hwave, but choppier)
|pulse| - Pulse text (transparency)
|rainbow| - Rainbow text
|clear| - Clear text effects without clearing color
|face:E(S)| - Modify King's face:
ABC is an expression - ANGER/HAPPY/SAD/NEUTRAL, adding S to the end adds shocked eyes.
|OUJI_#| - The name of Player #'s cousin, with color formatting (any undefined cousins show up as \"???\")."""
	#endregion
	new_button.disabled = true
	get_child(0).add_child(new_button)
	get_child(0).move_child(new_button, 1)

func _add_entry(entry_name:String):
	if TranslationServer.get_all_languages().has(end_bar.get_child(0).text):
		var entry:GKEditorPropertyDictEntry = GKEditorPropertyDialogEntry.new()
		entry.get_child(-1).text_changed.connect(_start_update)
		entries.push_back(entry)
		entry.property_name = entry_name
		add_child(entry)
		move_child(end_bar, -1)
