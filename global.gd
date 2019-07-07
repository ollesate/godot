extends Node

const STEP_SIZE = 75.0
const SPEED_MODIFIER = 1
const GENERAL_SPEED = 1.0 / SPEED_MODIFIER
const PLAYER_STEP_DURATION = GENERAL_SPEED
const PLAYER_STEP_WAIT = GENERAL_SPEED / 2
const PLAYER_ROTATION_DURATION = GENERAL_SPEED
const BULLET_SPEED = 400 * SPEED_MODIFIER
const CARD_PHASE_DURATION = 5 / SPEED_MODIFIER
const LASER_DURATION = 3 / SPEED_MODIFIER
const END_TURN_DURATION = 3 / SPEED_MODIFIER

var id = 0 setget , getId

func getId():
	id += 1
	return id 

var actions = []

func perform(action):
	actions.append(action)

func _physics_process(delta):
	for action in actions:
		if !action.isRunning:
			action.emit_signal("started")
		action.isRunning = true
		if action.act(delta):
			actions.remove(actions.find(action))
			action.emit_signal("finished")