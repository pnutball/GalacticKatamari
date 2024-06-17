@icon("res://editor/class_icons/GKEditorTreeItem.svg")
class_name GKEditorTreeItem
extends Resource

enum PropertyType {
	NUMBER, 
	VECTOR3, 
	STRING, 
	ARRAY, 
	BOOLEAN, 
	LOCALIZED, 
	DIALOGUE}

var parent_ref:WeakRef = null
@export var parent:GKEditorTreeItem:
	get:
		return parent_ref.get_ref()
	set(new_parent):
		parent_ref = weakref(new_parent)
@export var children:Array[GKEditorTreeItem] = []
var item_index:int = 0
var synced_tree_item:TreeItem = null:
	get:
		return synced_tree_item
	set(new_item):
		if new_item != null:
			synced_tree_item = new_item
			synced_tree_item.set_meta(&"property", self)

## Adds a child GKEditorTreeItem.
##
## Returns the child GKEditorTreeItem.
func add_child(child:GKEditorTreeItem) -> GKEditorTreeItem:
	children.push_back(child)
	child.parent = self
	return child

## Removes a child GKEditorTreeItem.
func remove_child(position:int) -> void:
	children[position].parent = null
	children.remove_at(position)

## Returns a JSON-compatible representation of this tree item and its children.
func to_json():
	return {}

## Creates a tree item and its children from a JSON source.
static func from_json(_from, _name:String = "") -> GKEditorTreeItem:
	return GKEditorTreeItem.new()

## Creates properties for this node and inserts it into "to".
func send_properties(to:BoxContainer) -> void:
	for child in to.get_children():
		child.queue_free()

## Internal function, instantiates property scenes.
func _create_property(container:BoxContainer, property_type:PropertyType, property:StringName, name:String = "Property", description:String = "Description") -> void:
	return

func _create_dropdown_property(container:BoxContainer, dropdown_items:Array[String], property:StringName, name:String = "Property", description:String = "Description") -> void:
	return

func _create_property_group(container:BoxContainer, name:String = "Group") -> BoxContainer:
	return BoxContainer.new()

## Creates a tree item for this EditorTreeItem.
func tree_sync(item:TreeItem) -> void:
	var this_item:TreeItem = item.create_child()
	synced_tree_item = this_item
	for level in children:
		level.tree_sync(this_item)
	return
