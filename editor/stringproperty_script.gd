extends Node

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	$PropertyName.text = P_Name
	$PropertyBox.text = P_Path.get(P_Property)
	$PropertyBox.text_changed.connect(_on_value_change)
	$PropertyName.tooltip_text = P_Tooltip

func _on_value_change(_value):
	ChangeMade.emit()
	if P_Path is Dictionary: P_Path[P_Property] = $PropertyBox.text
	else: P_Path.set(P_Property, $PropertyBox.text)
