class_name Action

var character: KinematicBody2D setget setCharacter, getCharacter
var isFirstTime = true
var firstTimePassed = false

func act(delta):
	if (firstTimePassed):
		isFirstTime = false
	firstTimePassed = true
	
func setCharacter(val):
	character = val

func getCharacter():
	return character