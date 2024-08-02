extends Control

@export var flipping:bool = false

var FatiguePrev:float = 1
var GroundOffset:float = 0
var DistOffset:Vector2 = Vector2.ZERO
@export_range(-1,1) var HeightMix:float = 1
@export_range(-1,1) var DistMix:float = 1

func _ready():
	%OujiAnimTree.active = true
	var OujiModel = load(GKGlobal.OujiInfo[GKGlobal.players[0][0]].get("Model")).instantiate()
	OujiModel.position = Vector3.ZERO
	OujiModel.scale = Vector3(0.038, 0.038, 0.038)
	$OujiViewportContainer/SubViewport/OujiViewRoot.add_child(OujiModel)
	%OujiAnimTree.anim_player = ^"../Ouji/OujiAnimation"

func flip(): 
	%OujiAnimTree.set("parameters/FlipOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	$OujiViewportContainer/SubViewport/OujiViewRoot/OujiFlipAnim.play("flip")
	await $OujiViewportContainer/SubViewport/OujiViewRoot/OujiFlipAnim.animation_finished
	DistMix = 1

func shot_finish():
	%OujiAnimTree.set("parameters/FinishMachine/conditions/StageEnding", false)
	%OujiAnimTree.set("parameters/FinishMachine/conditions/won", $"../SizeMeter".goal_reached($"..".Size, $"..".Score))
	%OujiAnimTree.set("parameters/FinishShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func shot_finish_end():
	%OujiAnimTree.set("parameters/FinishMachine/conditions/StageEnding", true)

func _process(delta):
	if not flipping:
		GroundOffset = ($"../FloorBumpDetect".global_position - $"../KatamariBody".global_position).y
		DistOffset = Vector2(0, 0.35 * $"..".Size + 0.02).rotated(-$"../SubViewport/KatamariCameraPivot".global_rotation.y)
	$OujiViewportContainer/SubViewport/OujiViewRoot.global_position = $"../KatamariBody".global_position + Vector3(
		DistOffset.x * DistMix * StageLoader.stageRoot.scale.x, 
		GroundOffset * HeightMix, 
		DistOffset.y * DistMix * StageLoader.stageRoot.scale.z
		)
	$OujiViewportContainer/SubViewport/OujiViewRoot.global_rotation.y = $"../SubViewport/KatamariCameraPivot".global_rotation.y - PI
	$OujiViewportContainer/SubViewport/OujiViewRoot.scale = StageLoader.stageRoot.scale * 1.31 * 0.05
	
	# Animate cousin model
	var rotatedVelocity = Vector2($"../KatamariBody".linear_velocity.x, $"../KatamariBody".linear_velocity.z).rotated($"..".CameraRotation)
	%OujiAnimTree.set("parameters/WalkState/conditions/idle_speed_reached", $"../KatamariBody".linear_velocity.length() < ($"..".Size / 10))
	%OujiAnimTree.set("parameters/WalkState/conditions/walk_speed_reached", $"../KatamariBody".linear_velocity.length() >= ($"..".Size / 10))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Roll/conditions/forward_condition", ($"..".StickMidpoint.angle_to(Vector2.UP) < (2.0*PI)/6.0) and ($"..".StickMidpoint.angle_to(Vector2.UP) > (-2.0*PI)/6.0))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Roll/conditions/backward_condition", ($"..".StickMidpoint.angle_to(Vector2.UP) > (4.0*PI)/6.0) or ($"..".StickMidpoint.angle_to(Vector2.UP) < (-4.0*PI)/6.0))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Roll/conditions/side_condition", ($"..".StickMidpoint.angle_to(Vector2.UP) > (2.0*PI)/6.0 and $"..".StickMidpoint.angle_to(Vector2.UP) < (4.0*PI)/6.0) or ($"..".StickMidpoint.angle_to(Vector2.UP) > (-4.0*PI)/6.0 and $"..".StickMidpoint.angle_to(Vector2.UP) < (-2.0*PI)/6.0))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Walk/conditions/not_backward_condition", (rotatedVelocity.angle_to(Vector2.UP) < (4.0*PI)/6.0) and (rotatedVelocity.angle_to(Vector2.UP) > (-4.0*PI)/6.0))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Walk/conditions/backward_condition", not (rotatedVelocity.angle_to(Vector2.UP) < (4.0*PI)/6.0) and (rotatedVelocity.angle_to(Vector2.UP) > (-4.0*PI)/6.0))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Walk/Forward/BodyRotAdd/add_amount", rotatedVelocity.normalized().x)
	%OujiAnimTree.set("parameters/WalkState/Ouji_Walk/Forward/HeadRotAdd/add_amount", rotatedVelocity.normalized().x)
	%OujiAnimTree.set("parameters/WalkState/Ouji_Roll/Forward/OujiForwardAdd/add_amount", lerpf(%OujiAnimTree.get("parameters/WalkState/Ouji_Roll/Forward/OujiForwardAdd/add_amount"), $"..".StickAngle, 0.5))
	%OujiAnimTree.set("parameters/MovementScale/scale", ($"..".Speed / 4.5) * lerp(FatiguePrev, 1 - (float($"..".Fatigued) * 0.5), clampf(0.5*((1.0 / 60)/delta), 0, 1)))
	%OujiAnimTree.set("parameters/TiredAdd/add_amount", lerpf(%OujiAnimTree.get("parameters/TiredAdd/add_amount"), ease($"..".DashFatigue / 100.0, 0.1) if $"..".Fatigued else 0.0, 0.5))
	%OujiAnimTree.set("parameters/WalkState/Ouji_Idle/Ouji_Turn/TurnAdd/add_amount", $"..".StickAngle * -0.75)
	FatiguePrev = 1 - (float($"..".Fatigued) * 0.5)
