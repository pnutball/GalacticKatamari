extends Node

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	$PropertyName.text = P_Name
	$PropertyBox.text = P_Path[P_Property.to_int() if P_Path is Array else P_Property]
	$PropertyBox.text_changed.connect(_on_value_change)
	$PropertyName.tooltip_text = P_Tooltip

func _on_value_change(_value):
	@warning_ignore("incompatible_ternary")
	if P_Path is Dictionary or P_Path is Array: P_Path[P_Property.to_int() if P_Path is Array else P_Property] = $PropertyBox.text
	else: P_Path.set(P_Property, $PropertyBox.text)
	ChangeMade.emit()
