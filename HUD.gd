extends Control

var playerHandsMap = {}
var playerCardScene = preload("ui_cards.tscn")

func _ready():
	Global.connect("onPlayerCards", self, "Global_onPlayerCards")
	Global.connect("onCardStart", self, "Global_onCardStart")
	Global.connect("onCardEnd", self, "Global_onCardEnd")
	
	var playerHands = get_tree().get_nodes_in_group("player_hands")
	for playerHand in playerHands:
		playerHand.visible = false
	var players = get_tree().get_nodes_in_group("players")
	print(players.size())
	for i in range(players.size()):
		playerHandsMap[players[i]] = playerHands[i]
		playerHands[i].visible = true

func Global_onPlayerCards(player, playerCards):
	var playerHand = playerHandsMap[player]
	playerHand.clear()
	for playerCard in playerCards:
		playerHand.addCard(playerCard.card)

func Global_onCardStart(player, card):
	playerHandsMap[player].onCardActivated(card)

func Global_onCardEnd(player, card):
	playerHandsMap[player].finishActivatedCards()