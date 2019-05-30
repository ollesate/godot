extends KinematicBody2D

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel

var id
var playerName
var color

func _ready():
	add_to_group("players")
	hp.hide()
	nameLabel.text = playerName
	if color:
		nameLabel.modulate = color
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func onHit(damage):
	hp.value -= damage
	hp.show()