extends Node

const StringBox = preload("res://editor/sub_property_localized_text.tscn")

signal ChangeMade
var P_Path
var P_Property:String
var P_Name = "Property"
var P_Tooltip:String = ""

func _ready():
	$PropertyHeader/PropertyName.text = P_Name
	$PropertyHeader/PropertyName.tooltip_text = P_Tooltip
	# Add English string first
	var EngText = StringBox.instantiate()
	EngText.get_node("SubPropertyLang").text = "en"
	EngText.get_node("SubPropertyLang").tooltip_text = TranslationServer.get_language_name("en")
	EngText.get_node("SubPropertyBox").text = P_Path.get(P_Property).get(&"en", "")
	EngText.get_node("SubPropertyBox").text_changed.connect(_on_value_change)
	EngText.get_node("SubPropertyBox").placeholder_text = "Blank text"
	$PropertyMargin/PropertyTexts.add_child(EngText)
	# Now add the rest
	for language in P_Path.get(P_Property).keys():
		if language != "en":
			var LocText = StringBox.instantiate()
			LocText.get_node("SubPropertyLang").text = language
			LocText.get_node("SubPropertyLang").tooltip_text = TranslationServer.get_language_name(language)
			LocText.get_node("SubPropertyBox").text = P_Path.get(P_Property).get(StringName(language), "")
			LocText.get_node("SubPropertyBox").text_changed.connect(_on_value_change)
			$PropertyMargin/PropertyTexts.add_child(LocText)
func _on_value_change(_value):
	var Texts:Dictionary = {}
	for language in P_Path.get(P_Property).keys():
		if P_Path.get(P_Property).get(StringName(language)) != "" or language == "en":
			Texts[language] = P_Path.get(P_Property).get(StringName(language))
	P_Path.set(P_Property, Texts)
	ChangeMade.emit()
