@tool
class_name GKRollableObject
extends PathFollow3D

const ENUMS = preload("res://scripts/lib/gk_object_enums.gd")

#region Graph stuff
@export var parents:Array[GKRollableObject]

@export var orphaned:bool: 
	get: return parents.all(func(obj): return obj.active)
	
@export var children:Array[GKRollableObject]

@export var childless:bool: 
	get: return children.all(func(obj): return obj.active)

#endregion

#region Object stuff

@export var object_id:StringName
# the following are autogenned from the object id:
var _bump_sound:AudioStreamWAV
var _roll_sound:AudioStreamWAV
var _texture:Texture2D
var _roll_texture:Texture2D

#endregion
