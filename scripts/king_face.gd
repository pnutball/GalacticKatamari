extends TextureRect

## Determines the mouth sprite used, depending on the expression.
@export_range(0, 3) var MouthShape:int = 0

## Determines whether the King's eyes are closed.
@export var EyesClosed:bool = false

enum KingExpression {NEUTRAL, HAPPY, ANGRY, SHOCK}

## Determines which facial expression is used.
@export var FacialExpression: KingExpression = KingExpression.NEUTRAL

## A dictionary of the textures used for each facial expression.
## In order:
## 1. Base face texture
## 2. Closed eyes texture
## 3. Mouth 0
## 4. Mouth 1
## 5. Mouth 2
## 6. Mouth 3
var Textures = {
	KingExpression.NEUTRAL: [preload("res://assets/textures/king/king_face.png"), preload("res://assets/textures/king/king_eye_close.png"), null, preload("res://assets/textures/king/king_mouth1.png"), preload("res://assets/textures/king/king_mouth2.png"), preload("res://assets/textures/king/king_mouth3.png")],
	KingExpression.HAPPY: [preload("res://assets/textures/king/king_face_happy.png"), preload("res://assets/textures/king/king_eye_close.png"), null, preload("res://assets/textures/king/king_mouth_smile1.png"), preload("res://assets/textures/king/king_mouth_smile2.png"), preload("res://assets/textures/king/king_mouth_smile3.png")],
	KingExpression.ANGRY: [preload("res://assets/textures/king/king_face_angry.png"), preload("res://assets/textures/king/king_eye_close_angry.png"), null, preload("res://assets/textures/king/king_mouth1.png"), preload("res://assets/textures/king/king_mouth2.png"), preload("res://assets/textures/king/king_mouth3.png")],
	KingExpression.SHOCK: [preload("res://assets/textures/king/king_face_shock.png"), preload("res://assets/textures/king/king_eye_close.png"), null, preload("res://assets/textures/king/king_mouth1.png"), preload("res://assets/textures/king/king_mouth2.png"), preload("res://assets/textures/king/king_mouth3.png")]
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	texture = Textures[FacialExpression][0]
	$KingEyes.texture = Textures[FacialExpression][1]
	$KingEyes.visible = EyesClosed
	$KingMouth.texture = Textures[FacialExpression][MouthShape + 2]
