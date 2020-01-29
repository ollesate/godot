class_name RotateAction
extends Action

var rotationSpeed
var duration

func _init(rotation, duration):
	self.rotationSpeed = deg2rad(rotation) / duration
	self.duration = duration

func act(delta):
	if (duration - delta < 0):
		# Prevent over rotation during speed up
		delta = duration
	duration -= delta

	character.rotate(rotationSpeed * delta)
	return duration <= 0
