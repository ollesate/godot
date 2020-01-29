class_name Action

signal started()
signal finished()

var character setget setCharacter, getCharacter
var isFirstTime = true
var firstTimePassed = false
var isRunning

func _init():
	connect("started", self, "start")
	connect("finished", self, "finish")

func act(delta):
	if (firstTimePassed):
		isFirstTime = false
	firstTimePassed = true

func start():
	pass

func finish():
	pass

func setCharacter(val):
	character = val

func getCharacter():
	return character

func with(character):
	self.character = character
	return self

func perform():
	Global.perform(self)
	return self
