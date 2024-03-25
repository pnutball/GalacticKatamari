extends Node

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	Set_P_Path()
	$PropertyName.text = P_Name
	$PropertyBox.value = P_Path[P_Property_Formatted()]
	$PropertyBox.value_changed.connect(_on_value_change)
	$PropertyName.tooltip_text = P_Name + "\nNumber\n\n" + P_Tooltip

func _on_value_change(_value):
	@warning_ignore("incompatible_ternary")
	if P_Path is Dictionary or P_Path is Array: P_Path[P_Property_Formatted()] = $PropertyBox.value
	else: P_Path.set(P_Property_Formatted(), $PropertyBox.value)
	ChangeMade.emit()

func P_Property_Formatted(): 
	var prop = P_Property.get_slice("/", P_Property.get_slice_count("/") - 1)
	return prop.to_int() if P_Path is Array else prop

func Set_P_Path():
	for slice in P_Property.get_slice_count("/") - 1:
		if P_Path is Dictionary or P_Path is Array: P_Path = P_Path[P_Property.get_slice("/", slice)]
		else: P_Path = P_Path.get(P_Property.get_slice("/", slice))
