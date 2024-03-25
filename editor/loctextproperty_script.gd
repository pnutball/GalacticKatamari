extends Node

const StringBox = preload("res://editor/sub_property_localized_text.tscn")

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	Set_P_Path()
	$PropertyHeader/PropertyName.text = P_Name
	$PropertyHeader/PropertyName.tooltip_text = P_Name + "\nLocalized text\n\n" + P_Tooltip
	# Add English string first
	addLanguage("en", true)
	# Now add the rest
	for language in P_Path.get(P_Property_Formatted()).keys():
		if language != "en": addLanguage(language.to_lower().strip_edges())
func _on_value_change(_value):
	var Texts:Dictionary = {}
	for entry in $PropertyMargin/PropertyTexts.get_children():
		if entry.get_node("SubPropertyBox").text != "" or entry.get_node("SubPropertyLang").text.to_lower() == "en":
			Texts[entry.get_node("SubPropertyLang").text.to_lower()] = entry.get_node("SubPropertyBox").text
	P_Path[P_Property] = Texts
	ChangeMade.emit()
func addLanguage(language:String, unremovable:bool = false):
	if TranslationServer.get_all_languages().has(language) and not $PropertyMargin/PropertyTexts.has_node(language):
		var LocText = StringBox.instantiate()
		LocText.name = language
		LocText.get_node("SubPropertyLang").text = language + ":"
		LocText.get_node("SubPropertyLang").tooltip_text = TranslationServer.get_language_name(language)
		LocText.get_node("SubPropertyBox").text = P_Path.get(P_Property_Formatted()).get(language, "").json_escape()
		LocText.get_node("SubPropertyBox").text_changed.connect(_on_value_change)
		if unremovable: LocText.get_node("SubPropertyBox").placeholder_text = "Blank text"
		$PropertyMargin/PropertyTexts.add_child(LocText)
func toggleShown():
	var vis:bool = $PropertyMargin.visible
	$PropertyHeader/CollapseButton.icon = preload("res://editor/icons/expand.png") if vis else preload("res://editor/icons/collapse.png")
	$PropertyMargin.visible = not vis
	$PropertyAdd.visible = not vis
	$PropertyHeader/CollapseButton.tooltip_text = "Collapse list" if vis else "Expand list"
func appendNewLanguage():
	addLanguage($PropertyAdd/PropertyBox.text.to_lower().strip_edges())
	$PropertyAdd/PropertyBox.text = ""
func P_Property_Formatted(): 
	var prop = P_Property.get_slice("/", P_Property.get_slice_count("/") - 1)
	return prop.to_int() if P_Path is Array else prop
func Set_P_Path():
	for slice in P_Property.get_slice_count("/") - 1:
		if P_Path is Dictionary or P_Path is Array: P_Path = P_Path[P_Property.get_slice("/", slice)]
		else: P_Path = P_Path.get(P_Property.get_slice("/", slice))
