extends Action

class_name AlertAction

var text

func _init(text):
	self.text = text

func act(delta):
	Global.alert(text)
	return true