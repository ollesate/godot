extends KinematicBody2D

signal onHit()
signal onDestroyed()

const HP_MAX = 9

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel

var id
var playerName = ""
var color = Color.white
var hpMax = HP_MAX
var currentHp setget , getHp

func _ready():
	add_to_group("players")
	hp.max_value = hpMax
	hp.hide()
	nameLabel.text = playerName
	if color:
		nameLabel.modulate = color
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func setInfo(info):
	id = info.id
	if info.name:
		playerName = info.name
	else:
		playerName = str("Player", id)
	if info.color:
		color = info.color
	else:
		color = Color.white
	nameLabel.modulate = color
	nameLabel.text = playerName

func getHp():
	return hp.value

func onHit(damage):
	hp.value -= damage
	hp.show()
	emit_signal("onHit", self)	
	if hp.value <= 0:
		emit_signal("onDestroyed", self)
		queue_free()