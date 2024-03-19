extends Node

var P_Path
var P_Property:String
var P_Name = "Property"

func _ready():
	$PropertyName.text = P_Name
	$PropertyBox.text = P_Path.get(P_Property)
	$PropertyBox.text_changed.connect(_on_value_change)

func _on_value_change(_value):
	P_Path.set(P_Property, $PropertyBox.text)
