extends Action

class_name Wait

var duration
var otherAction

func _init(duration, otherAction = null):
	self.duration = duration
	self.otherAction = otherAction
	if (otherAction != null):
		self.name = otherAction.name

func setCharacter(character):
	.setCharacter(character)
	if (otherAction != null):
		otherAction.character = character

func act(delta):
	duration -= delta
	if (duration < 0):
		if (otherAction == null):
			return true
		return otherAction.act(delta)