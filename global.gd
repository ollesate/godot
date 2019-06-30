extends Node

const STEP_SIZE = 128.0
const SPEED_MODIFIER = 1
const GENERAL_SPEED = 1.0 / SPEED_MODIFIER
const PLAYER_STEP_DURATION = GENERAL_SPEED
const PLAYER_STEP_WAIT = GENERAL_SPEED / 2
const PLAYER_ROTATION_DURATION = GENERAL_SPEED
const BULLET_SPEED = 400 * SPEED_MODIFIER
const CARD_PHASE_DURATION = 5 / SPEED_MODIFIER
const LASER_DURATION = 3 / SPEED_MODIFIER
const END_TURN_DURATION = 3 / SPEED_MODIFIER

# onready var events = get_node("/root/Root/HUD/Events")

signal onCardStart(player, card)
signal onCardEnd(player, card)
signal onPlayerCards(player, cards)

var actions = []
var drawActions = []

func onPlayerCards(player, cards):
	emit_signal("onPlayerCards", player, cards)
	
func onCardStart(player, card):
	emit_signal("onCardStart", player, card)	

func onCardEnd(player, card):
	emit_signal("onCardEnd", player, card)

func perform(action):
	actions.append(action)

func _physics_process(delta):
	for i in range(actions.size()):
		var action = actions[i]
		if !action.isRunning:
			action.emit_signal("started")
		action.isRunning = true
		if action.act(delta):
			actions.remove(i)
			action.emit_signal("finished")