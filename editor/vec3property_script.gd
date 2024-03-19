extends Node

var P_Path
var P_Name = "Property"

func _ready():
	$PropertyName.text = P_Name
	$PropertyHBox/Xbox.value = P_Path[0]
	$PropertyHBox/Ybox.value = P_Path[1]
	$PropertyHBox/Zbox.value = P_Path[2]
	for box:SpinBox in $PropertyHBox.get_children():
		box.value_changed.connect(_on_value_change)

func _on_value_change(_value):
	P_Path[0] = $PropertyHBox/Xbox.value
	P_Path[1] = $PropertyHBox/Ybox.value
	P_Path[2] = $PropertyHBox/Zbox.value
