extends Control

## Enables the timer's process.
@export var enabled:bool = false:
	set(newEnabled):
		enabled = newEnabled
	get:
		return enabled

## The current amount of time remaining, in seconds.[br]
## Setting time to a value higher than maximum_time will increase maximum_time to match. 
var time:float = 60:
	set(newTime):
		time = newTime
		@warning_ignore("narrowing_conversion")
		if maximum_time < newTime: maximum_time = newTime
	get:
		return time
## The maximum amount of time available, in seconds.
var maximum_time:int = 60:
	set(newMax):
		if time > newMax: maximum_time = ceili(time)
		else: maximum_time = newMax
	get:
		return maximum_time

var previous_time:float

## Emitted when the timer reaches 0.
signal timeout

## Emitted when the timer reaches 1 minute (time = 60)
signal minute_remaining

## Scrolls in the timer, making it visible.
## If the timer is enabled before this function is called, the timer will fade in instead.
## Does nothing if the timer is already visible.
func scroll_in():
	if not $TimerScrollAnimation.is_playing():
		if time >= 60:
			$TimerBody/TimerText.text = str(ceili(time/60))
		else:
			$TimerBody/TimerText.text = str(ceili(time))
		$TimerScrollAnimation.play("Scroll")

## Scrolls out the timer, making it invisible.
## Does nothing if the timer is already invisible.
func scroll_out():
	if not $TimerScrollAnimation.is_playing():
		enabled = false
		$TimerScrollAnimation.play("Unscroll")

## Fades in the timer, making it visible.
## This function is called automatically if the timer is active while the timer is invisible.
## Does nothing if the timer is already visible.
func fade_in():
	if not $TimerScrollAnimation.is_playing():
		if time >= 60:
			$TimerBody/TimerText.text = str(ceili(time/60))
		else:
			$TimerBody/TimerText.text = str(ceili(time))
		$TimerScrollAnimation.play("Fade")

## Fades out the timer, making it invisible.
## Does nothing if the timer is already invisible.
func fade_out():
	if not $TimerScrollAnimation.is_playing():
		enabled = false
		$TimerScrollAnimation.play_backwards("Fade")

## Returns the amount of time remaining, using the format string as a template. Use "%d" as a placeholder.
func get_time(format:String = "%d:%d", secondsFirst:bool = false):
	if secondsFirst: return format % [int(time) % 60, int(time) / 60]
	else: return format % [int(time) / 60, int(time) % 60]

## Returns the maximum amount of time, using the format string as a template. Use "%d" as a placeholder.
func get_maximum_time(format:String = "%d:%d", secondsFirst:bool = false):
	if secondsFirst: return format % [maximum_time % 60, maximum_time / 60]
	else: return format % [maximum_time / 60, maximum_time % 60]

func _ready():
	$TimerAnimation.animation_set_next(&"MinuteSpin", &"SecondSpin_Transition")
	$TimerAnimation.animation_set_next(&"SecondSpin_Transition", &"SecondSpin")

func _process(delta):
	
	if enabled:
		
		if $TimerBody.position.x > 0 and not $TimerScrollAnimation.is_playing():
			fade_in()
		
		previous_time = time
		time = maxf(time - delta, 0)
		
		if floori(time) != floori(previous_time) and floori(time) < 31: $TimerAudio.play() 
		if floori(time) < floori(previous_time) and floori(previous_time) >= 60 and floori(time) < 60: 
			minute_remaining.emit()
			DialogueBox.queue_message("")
			DialogueBox.queue_message("You've got |color:#FF4D3D|one minute|color:#FFFFFF| left.\n|vwave|Keep rolling until you can't anymore!")
			DialogueBox.speak_queue()
		
		if time >= 60:
			$TimerBody/TimerText.text = str(ceili(time/60))
			if $TimerAnimation.current_animation != "MinuteSpin": $TimerAnimation.current_animation = "MinuteSpin"
			$TimerAnimation.speed_scale = ((maximum_time - 60) / 60)
			$TimerAnimation.seek((maximum_time - time) * (60.0 / (maximum_time - 60)))
		elif time >= 59:
			$TimerBody/TimerText.text = str(floori(time))
			if $TimerAnimation.current_animation != "SecondSpin_Transition": $TimerAnimation.current_animation = "SecondSpin_Transition"
			if $TimerAnimation.current_animation_position != (1 + (floori(time) - time)): $TimerAnimation.seek(1 + (floori(time) - time))
		elif time > 0:
			$TimerBody/TimerText.text = str(floori(time))
			if $TimerAnimation.current_animation != "SecondSpin": $TimerAnimation.current_animation = "SecondSpin"
			if $TimerAnimation.current_animation_position != (1 + (floori(time) - time)): $TimerAnimation.seek(1 + (floori(time) - time))
		else:
			if $TimerAnimation.current_animation != "Halt":
				$TimerAnimation.play("Halt")
				enabled = false
				timeout.emit()
				
	elif $TimerAnimation.is_playing() and $TimerAnimation.current_animation != "Halt": $TimerAnimation.pause()
