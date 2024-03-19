extends Node

func _ready():
	$PropertyName.text = get_meta(&"name", "Property")
	$PropertyHBox/Xbox.value = get_meta(&"path", [0,0,0])[0]
	$PropertyHBox/Ybox.value = get_meta(&"path", [0,0,0])[1]
	$PropertyHBox/Zbox.value = get_meta(&"path", [0,0,0])[2]
	for box:SpinBox in $PropertyHBox.get_children():
		box.value_changed.connect(_on_value_change)

func _on_value_change(_value):
	get_meta(&"path")[0] = $PropertyHBox/Xbox.value
	get_meta(&"path")[1] = $PropertyHBox/Ybox.value
	get_meta(&"path")[2] = $PropertyHBox/Zbox.value
