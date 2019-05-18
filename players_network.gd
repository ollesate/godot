extends Node

var cards = []

remotesync func dealCards(cards):
	self.cards = cards

remotesync func swap(cardIdx1, cardIdx2):
	var temp = cards[cardIdx1]
	cards[cardIdx1] = cards[cardIdx2]
	cards[cardIdx2] = temp
	
func getCards():
	return cards