extends Node

func _ready():
	$PropertyName.text = get_meta(&"name", "Property")
	$PropertyBox.value = get_meta(&"path", 0)
	$PropertyBox.value_changed.connect(_on_value_change)

func _on_value_change(_value):
	get_meta(&"path") = $PropertyBox.value
