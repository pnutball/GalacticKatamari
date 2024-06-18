@icon("res://editor/class_icons/GKEditorPropertyString.svg")
class_name GKEditorPropertyDialogEntry
extends GKEditorPropertyDictEntry

func _init():
	vertical = true
	property_type = "Entry"

func _ready():
	var name_node:Label = Label.new()
	name_node.text = property_name
	name_node.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_node.size_flags_stretch_ratio = 2
	name_node.name = "NameLabel"
	add_child(name_node)
	var str_node:TextEdit = TextEdit.new()
	str_node.size_flags_stretch_ratio = 3
	name_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	str_node.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	str_node.select_all_on_focus = true
	str_node.custom_minimum_size.y = 150
	str_node.draw_control_chars = true
	var syntax := CodeHighlighter.new()
	syntax.add_keyword_color("|break|", Color.DARK_GRAY)
	syntax.add_color_region("|color:", "|", Color.CORNFLOWER_BLUE)
	syntax.add_color_region("|bgcolor:", "|", Color.STEEL_BLUE)
	syntax.add_keyword_color("|vwave|", Color.MEDIUM_PURPLE)
	syntax.add_keyword_color("|hwave|", Color.PALE_VIOLET_RED)
	syntax.add_keyword_color("|jitter|", Color.MEDIUM_VIOLET_RED)
	syntax.add_keyword_color("|pulse|", Color.SLATE_GRAY)
	syntax.add_keyword_color("|rainbow|", Color.ORANGE)
	syntax.add_keyword_color("|clear|", Color.ANTIQUE_WHITE)
	syntax.add_color_region("|face:", "|", Color.YELLOW)
	syntax.add_color_region("|ouji_", "|", Color.PALE_GREEN)
	str_node.syntax_highlighter = syntax
	str_node.text_changed.connect(_update_property)
	add_child(str_node)
