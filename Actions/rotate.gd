class_name RotateAction
extends Action

var rotation
var duration

func _init(rotation, duration):
	self.rotation = deg2rad(rotation)
	self.duration = duration

func act(delta):
	duration -= delta
	character.rotate(rotation * delta)
	return duration <= 0