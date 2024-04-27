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
	%PreviewViewport/MeshPreview.rotate_y(PI/8 * delta)


func _object_selected(index):
	var objName = $ObjectScroll/ObjectList.get_item_text(index)
	%PreviewViewport/MeshPreview.mesh = load(StageLoader.objectList.objects.get(objName).view_mesh)
	%PreviewViewport/MeshPreview.material_override.albedo_texture = load(StageLoader.objectList.objects.get(objName).texture)
	#%PreviewViewport/MeshPreview.scale = Vector3(StageLoader.objectList.objects.get(objName).scale, StageLoader.objectList.objects.get(objName).scale, StageLoader.objectList.objects.get(objName).scale)
