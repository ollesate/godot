extends Action

class_name Sequence

var actions = []

func _init(actions):
	self.actions = actions

func setCharacter(character):
	for action in actions:
		action.character = character

func act(delta):
	if (actions.size() == 0):
		return true
	if (actions[0].act(delta)):
		actions.remove(0)