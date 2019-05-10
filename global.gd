extends Node

const ACTION_SPEED = 1.0
const PLAYER_STEP_SPEED = 1.0
const PLAYER_STEP_WAIT = 1.0

var events
var hud

signal onCardStart(player, card)
signal onCardEnd(player, card)
signal onPlayerCards(player, cards)

func _ready():
	events = get_node("/root/Root/HUD/Events")
	hud = get_node("/root/Root/HUD/")

func alert(text):
	events.onEvent(text)
	
func onPlayerCards(player, cards):
	emit_signal("onPlayerCards", player, cards)
	
func onCardStart(player, card):
	emit_signal("onCardStart", player, card)	

func onCardEnd(player, card):
	emit_signal("onCardEnd", player, card)