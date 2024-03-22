extends Node

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	$PropertyButton.text = P_Name
	$PropertyButton.set_pressed(P_Path.get(P_Property))
	$PropertyButton.toggled.connect(_on_value_change)
	$PropertyButton.tooltip_text = P_Tooltip

func _on_value_change(value):
	@warning_ignore("incompatible_ternary")
	if P_Path is Dictionary or P_Path is Array: P_Path[P_Property.to_int() if P_Path is Array else P_Property] = value
	else: P_Path.set(P_Property, value)
	ChangeMade.emit()
