class_name ScaleAction
extends Action

var startDuration

var scaleTo
var scaleFrom
var duration

func _init(scaleTo, duration):
	self.startDuration = duration
	self.scaleTo = Vector2(scaleTo, scaleTo)
	self.duration = duration

func start():
	scaleFrom = character.scale

func act(delta):
	character.scale = lerp(scaleFrom, scaleTo, (startDuration - duration) / startDuration)
	duration -= delta
	return duration <= 0