class_name Cards

enum {MOVE, ROTATE}

static func generate(nCards):
	var cards = []
	for i in range(nCards):
		cards.append(generateCard())
	return cards
						
static func generateCard():
	randomize()
	var type = randi() % 2
	match(type):
		0:
			var steps = randi() % 4 + 1
			var movement = randi() % 2
			match(movement):
				0:
					var stepActions = []
					for step in range(steps):
						stepActions.append(Player.movesStep(Player.FORWARD))
					return MultiStepCard.new(
						Sequence.new(stepActions), 
						str("Move forward ", steps, " steps"),
						MOVE)
				1:
					var stepActions = []
					for step in range(steps):
						stepActions.append(Player.movesStep(Player.BACKWARDS))
					return MultiStepCard.new(
						Sequence.new(stepActions), 
						str("Move backwards ", steps, " steps"),
						MOVE)
		1:
			var rotation = randi() % 3
			match(rotation):
				0:
					return Card.new(
						Player.rotateAction(Player.LEFT), 
						"Rotate left",
						ROTATE)
				1:
					return Card.new(
						Player.rotateAction(Player.RIGHT), 
						"Rotate right",
						ROTATE)
				2:
					return Card.new(
						Player.rotateAction(Player.UTURN), 
						"Rotate uturn",
						ROTATE)

static func moveAction(direction, steps):
	var stepActions = []
	for step in range(steps):
		stepActions.append(Player.moveStep(direction))
	var description
	match(direction):
		Player.FORWARD:
			description = str("Move backwards ", steps, " steps")
		Player.BACKWARDS:
			description = str("Move backwards ", steps, " steps")
			
	return MultiStepCard.new(
		Sequence.new(stepActions),
		description,
		MOVE)

class Card:
	extends CompositeAction
	
	var description
	var action
	var type
	
	func _init(action, description, type).([action]):
		self.description = description
		self.action = action
		self.type = type
		
	func setCharacter(val):
		.setCharacter(val)
		if val:
			val.connect("onDestroyed", self, "onDestroyed")
		
	func onDestroyed(player):
		character = null
		
	func act(delta):
		if !character: # Player has died
			return true
		return action.act(delta)

# This card was needed becauase we wanted a way to know if a player should die in middle of a move
class MultiStepCard:
	extends Card
	
	signal stepFinished()
	
	func _init(sequence, description, type).(sequence, description, type):
		sequence.connect("stepFinished", self, "stepFinished")
		
	func stepFinished(stepsLeft):
		emit_signal("stepFinished", stepsLeft)