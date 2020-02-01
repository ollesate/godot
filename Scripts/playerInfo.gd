class_name PlayerInfo

signal onUpdate()

var id setget setId
var name setget setName
var color setget setColor

func _init(id, name, color):
	self.id = id
	self.name = name
	self.color = color
	
func setId(val):
	id = val
	emit_signal("onUpdate")
	
func setName(val):
	name = val
	emit_signal("onUpdate")
	
func setColor(val):
	color = val
	emit_signal("onUpdate")