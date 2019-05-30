class_name CardUtils

enum {MOVE, ROTATE, SIZE}

static func generateCards():
	var cards = []
	for i in range(5):
		cards.append(generateCard())
	return cards

static func generateCard():
	var action
	randomize()
	match randi() % SIZE:
		MOVE:
			action = PlayerMove.new(PlayerMove.randDirection(), PlayerMove.randSteps())
		ROTATE:
			action = Rotate.new(Rotate.randRotation())
	return CardWrapper.new(action)

class CardWrapper:
	
	signal onCardStarted()
	signal onCardFinished()
	
	extends Card
	
	var card
	
	func _init(card):
		self.card = card
		self.description = card.description

	func setCharacter(newCharacter):
		character = newCharacter
		card.character = newCharacter
		
	func act(delta):
		.act(delta)
		
		if self.isFirstTime:
			emit_signal("onCardStarted", self)
		
		if card.act(delta):
			emit_signal("onCardFinished", self)
			return true
		return false