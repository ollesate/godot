extends Action

class_name CompositeAction

var actions = []

func _init(actions = []):
	self.actions = actions

func setCharacter(val):
	character = val
	for action in actions:
		action.character = val