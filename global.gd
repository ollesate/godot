extends Node

const ACTION_SPEED = 1.0
const PLAYER_STEP_SPEED = 1.0
const PLAYER_STEP_WAIT = 1.0

var events

func _ready():
	events = get_node("/root/Root/HUD/Events")

func alert(text):
	events.onEvent(text)