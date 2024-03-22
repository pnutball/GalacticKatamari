extends Node

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Items:Array[String] = [""]
var P_Tooltip:String = ""

func _ready():
	$PropertyName.text = P_Name
	for item in P_Items:
		$PropertyBox.add_item(item)
		if item == P_Path.get(P_Property): $PropertyBox.selected = $PropertyBox.item_count - 1
	$PropertyBox.item_selected.connect(_on_value_change)
	$PropertyName.tooltip_text = P_Tooltip

func _on_value_change(item):
	@warning_ignore("incompatible_ternary")
	if P_Path is Dictionary or P_Path is Array: P_Path[P_Property.to_int() if P_Path is Array else P_Property] = $PropertyBox.get_item_text(item)
	else: P_Path.set(P_Property, $PropertyBox.get_item_text(item))
	ChangeMade.emit()
