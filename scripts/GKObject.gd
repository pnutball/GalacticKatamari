@tool
@icon("res://addons/gk_editor_tools/icons/gk_object.svg")
class_name GKRollableObject
extends PathFollow3D

const ENUMS = preload("res://scripts/lib/gk_object_enums.gd")

#region Graph stuff
@export var active:bool = true

@export var parents:Array[GKRollableObject]

var orphaned:bool: 
	get: return parents.all(func(obj): return obj.active)
	
#@export var children:Array[GKRollableObject]

#@export var childless:bool: 
#	get: return children.all(func(obj): return obj.active)

#endregion

#region Object stuff
## The Object ID (sourced from [code]res://data/objects.json[/code]) that this object uses.[br]
## The object's audio, model, collision, & textures are set based on this ID.
@export var object_id:StringName
# the following are autogenned from the object id:
var _bump_sound:AudioStreamWAV
var _roll_sound:AudioStreamWAV
var _texture:Texture2D
var _roll_texture:Texture2D
var _model:Mesh
var _collision_shape:Shape3D

@export_group("Behavior")
@export_subgroup("Movement")
## The movement speed when the katamari [u]can't[/u] roll up/knock over this object.[br][br]
## [b]Positive numbers:[/b] The object runs away from the katamari.[br]
## [b]Negative numbers:[/b] The object approaches the katamari.[br]
## [b]Zero:[/b] This object does not move differently.
@export var speed_small:float = 0
## The movement speed when the katamari [u]can[/u] roll up/knock over this object.[br][br]
## [b]Positive numbers:[/b] The object runs away from the katamari.[br]
## [b]Negative numbers:[/b] The object approaches the katamari.[br]
## [b]Zero:[/b] This object does not move differently.
@export var speed_large:float = 0
## The distance this object will roam relative to its usual position. [br]
## If the object reaches the edge of its roam distance or bumps into a wall, it'll move in a random direction. [br]
## If set to 0, the object will not roam.
@export var roaming_distance:float = 0:
	get: return roaming_distance
	set(new): roaming_distance = max(new, 0)
#endregion

func _validate_property(property: Dictionary) -> void:
	if property.name in ["speed_small", "speed_large", "roaming_distance"] and get_parent() is Path3D:
		property.usage = property.usage + PROPERTY_USAGE_READ_ONLY
