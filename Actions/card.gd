extends Action

class_name Card

static func wait():
	return CardWait.new()

static func perform(action, character = null):
	var card = CardWrapper.new(action)
	if character:
		card.character = character
	Global.perform(card)
	return card

var description = "No description yet"

func act(delta):
	.act(delta)

class CardWait:
	extends Action
	
	var description = "Wait"
	var wait
	
	func _init():
		wait = Wait.new(2)
	
	func act(delta):
		.act(delta)
		return wait.act(delta)

class CardWrapper:
	extends Action
	
	signal started()
	signal finished()
	
	var card
	var description
	
	func _init(card):
		self.card = card
		if card.get("description"):
			description = card.description

	func setCharacter(newCharacter):
		character = newCharacter
		card.character = newCharacter
		
	func act(delta):
		.act(delta)
		
		if self.isFirstTime:
			emit_signal("started", self)
		
		if card.act(delta):
			emit_signal("finished", self)
			return true
		return false
	