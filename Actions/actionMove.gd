class_name ActionMove
extends Action

var speed
var direction
var duration
var velocity

func _init(direction, duration, speed):
	self.direction = direction
	self.speed = speed
	self.duration = duration
	self.velocity = direction * speed / duration
	
func act(delta):
	.act(delta)
	if not character:
		return true
	character.move_and_slide(velocity)
	duration -= delta
	if duration <= 0:
		return true