extends Control

## The base position of the King's face & moya, relative to the screen center.
##
## Recommended position bounds, for future reference:
## X: -700 to 700 (left to right)
## Y: -310 to 310 (top to bottom)
var MoyaPosition:Vector2 = Vector2(0,-310)
## The position modifier of the King's face & moya.
var MoyaPositionModifier:Vector2 = Vector2(0,0)

func _ready():
	$MoyaWibbleAnimation.play("moya_wibble")
	#$BounceAnimation.play("king_bounce")
	# This will be added back at a later date.

func _process(delta):
	$MoyaPos.position = MoyaPosition + MoyaPositionModifier - Vector2(170, 170)
