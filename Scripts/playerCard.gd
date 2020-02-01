extends Action

class_name PlayerCard

var card
var description

func _init(card):
	self.card = card
	description = card.description

func act(delta):
	.act(delta)
	if self.isFirstTime:
		Global.onCardStart(card.character, card)
	var finished = card.act(delta)
	if finished:
		Global.onCardEnd(card.character, card)
	return finished