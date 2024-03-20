extends Node

var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	$PropertyName.text = P_Name
	$PropertyBox.value = P_Path.get(P_Property)
	$PropertyBox.value_changed.connect(_on_value_change)
	$PropertyName.tooltip_text = P_Tooltip

func _on_value_change(_value):
	P_Path.set(P_Property, $PropertyBox.value)
