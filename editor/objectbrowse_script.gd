extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	for object in StageLoader.objectList.objects.keys():
		$ObjectScroll/ObjectList.add_item(object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ObjectScroll/ObjectList.fixed_column_width = $ObjectScroll/ObjectList.size.x / int($ObjectScroll/ObjectList.size.x / 220)
