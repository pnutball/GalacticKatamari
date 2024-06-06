extends Control

func _ready():
	%OujiAnimTree.active = true

func _process(_delta):
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
	%OujiAnimTree.set("parameters/MovementScale/scale", $"..".Speed / 4.5)
