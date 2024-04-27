extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	for object in StageLoader.objectList.objects.keys():
		$ObjectScroll/ObjectList.add_item(object)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var width:int = $ObjectScroll/ObjectList.size.x
	$ObjectScroll/ObjectList.max_columns = int(width / 220)
	$ObjectScroll/ObjectList.fixed_column_width = int(width / $ObjectScroll/ObjectList.max_columns) - 8
