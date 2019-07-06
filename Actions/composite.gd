extends Action

class_name CompositeAction

var actions = [] setget setActions

func _init(actions = []):
	self.actions = actions

func setActions(val):
	actions = val

func start():
	for action in actions:
		action.emit_signal("started")

func setCharacter(val):
	character = val
	for action in actions:
		action.character = val