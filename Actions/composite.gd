extends Action

class_name CompositeAction

var actions = []

func _init(actions):
	self.actions = actions

func setCharacter(character):
	for action in actions:
		action.character = character