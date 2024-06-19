@icon("res://editor/class_icons/GKEditorProperty.svg")
class_name GKEditorPropertyGroup
extends GKEditorProperty

const ICON_EXPAND:Texture2D = preload("uid://b6umlml5fbrbc")
const ICON_COLLAPSE:Texture2D = preload("uid://b480uhh3ecl0l")
var showhide_button:Button = Button.new()
var collapsed = false

func _init():
	vertical = true
	property_type = "Group"

func _ready():
	var header_node:HBoxContainer = HBoxContainer.new()
	header_node.name = "Header"
	add_child(header_node)
	
	var name_node:Label = Label.new()
	name_node.text = property_name
	name_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_node.size_flags_stretch_ratio = 2
	name_node.mouse_filter = Control.MOUSE_FILTER_STOP
	name_node.tooltip_text = "%s\n%s\n\n%s" % [String(property_name), property_type, property_description]
	name_node.name = "NameLabel"
	header_node.add_child(name_node)
	
	showhide_button.icon = ICON_COLLAPSE
	showhide_button.tooltip_text = "Collapse"
	showhide_button.pressed.connect(_show_hide)
	header_node.add_child(showhide_button)

func _show_hide():
	for child in get_children():
		if child.name != "Header": child.visible = collapsed
	collapsed = not collapsed
	showhide_button.icon = ICON_EXPAND if collapsed else ICON_COLLAPSE
	showhide_button.tooltip_text = "Expand" if collapsed else "Collapse"
