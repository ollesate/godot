extends Control

var cardLabelScene = preload("res://ui_card.tscn")
var cardLabels = {}

func _ready():
	add_to_group("player_hands")

func add(text):
	var cardLabel = cardLabelScene.instance()
	cardLabel.setText(text)
	$CardContainer.add_child(cardLabel)

func addCard(card, isLocked = false):
	var cardLabel = cardLabelScene.instance()
	cardLabel.setText(card.description)
	cardLabels[card] = cardLabel
	$CardContainer.add_child(cardLabel)
	
func clear():
	cardLabels.clear()
	for child in $CardContainer.get_children():
		child.free()

func finishActivatedCards():
	for label in cardLabels.values():
		if (label.state == CardLabel.ACTIVE):
			label.state = CardLabel.FINISHED

func onCardActivated(card):
	cardLabels[card].state = CardLabel.ACTIVE