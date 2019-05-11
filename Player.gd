extends KinematicBody2D

onready var hp = $"UI/HP"

func _ready():
	add_to_group("players")
	hp.hide()

func _physics_process(delta):
	pass

func getCards():
	return createCards()

func onHit(damage):
	hp.value -= damage
	hp.show()

func createCards():
	var cards = []
	for x in range(5):
		var card = Cards.generateCard(self)
		cards.append(card)
	return cards

class Cards:
	enum {MOVE, ROTATE, SIZE}
	
	static func generateCard(character):
		var action
		randomize()
		match randi() % SIZE:
			MOVE:
				action = Move.new(Move.randDirection(), Move.randSteps())
			ROTATE:
				action = Rotate.new(Rotate.randRotation())
		action.character = character
		return action
		

class Move:
	extends Card

	const FORWARD = Vector2.UP
	const BACK = Vector2.DOWN
	const SIDEWAYS_LEFT = Vector2.LEFT
	const SIDEWAYS_RIGHT = Vector2.RIGHT
	const WAIT_TIME = Global.PLAYER_STEP_WAIT
	const MAX_STEPS = 4
	
	const DIRECTIONS = [FORWARD, BACK, SIDEWAYS_LEFT, SIDEWAYS_RIGHT]
	
	var action
	var direction
	var steps
	
	static func randDirection():
		return DIRECTIONS[randi() % 2]
	
	static func randSteps():
		return randi() % MAX_STEPS + 1
	
	func _init(direction, steps):
		self.direction = direction
		self.steps = steps
		var actions = []
		for x in steps:
			actions.append(MoveStep.new(direction, true))
			if (x < steps - 1):
				actions.append(Wait.new(WAIT_TIME))
		action = Sequence.new(actions)
		self.description = getText()
		
	func getText():
		match direction:
			FORWARD:
				return str("Move forward ", steps)
			SIDEWAYS_LEFT:
				return str("Move sideways left ", steps)
			SIDEWAYS_RIGHT:
				return str("Move sideways right ", steps)
			BACK:
				return str("Move back ", steps)
		
	func setCharacter(character):
		.setCharacter(character)
		action.setCharacter(character)
	
	func act(delta):
		.act(delta)
		return action.act(delta)