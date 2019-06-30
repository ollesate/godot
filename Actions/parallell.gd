extends CompositeAction

class_name Parallell

func _init(actions).(actions):
	pass

func act(delta):
	var i = actions.size() - 1
	while i >= 0:
		if (actions[i].act(delta)):
			actions[i].emit_signal("finished")
			actions.remove(i)
		i -= 1
	return actions.size() == 0
	
func start():
	for action in actions:
		action.emit_signal("started")