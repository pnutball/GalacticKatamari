extends Node

var P_Path
var P_Property:String
var P_Name = "Property"
var P_Items:Array[String] = [""]

func _ready():
	$PropertyName.text = P_Name
	for item in P_Items:
		$PropertyBox.add_item(item)
		if item == P_Path.get(P_Property): $PropertyBox.selected = $PropertyBox.item_count - 1
	$PropertyBox.item_selected.connect(_on_value_change)

func _on_value_change(item):
	P_Path.set(P_Property, $PropertyBox.get_item_text(item))
