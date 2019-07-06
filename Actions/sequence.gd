extends Action

class_name Sequence

var actions = []
var isNew

func _init(actions):
	self.actions = actions

func setCharacter(character):
	for action in actions:
		action.character = character

func act(delta):
	if (actions.size() == 0):
		return true
	if !isNew:
		isNew = true
		actions[0].emit_signal("started")
	if (actions[0].act(delta)):
		actions[0].emit_signal("finished")
		actions.remove(0)
		isNew = false