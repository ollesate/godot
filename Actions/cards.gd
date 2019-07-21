class_name Cards

enum {MOVE, ROTATE}
enum {ROTATE_LEFT, ROTATE_RIGHT, UTURN}
enum {MOVE_FORWARD, MOVE_BACKWARDS}

static func generateCardInfos(nCards):
	var infos = []
	for i in range(nCards):
		infos.append(generateInfo())
	return infos

static func generateInfo():
	randomize()
	var type = randi() % 2
	var id = Global.getId()
	match(type):
		0:
			var steps = randi() % 4 + 1
			var movement = randi() % 2
			var description
			match movement:
				0:
					description = str("Move forward ", steps, " steps")
				1:
					description = str("Move backwards ", steps, " steps")
			return {"description": description, "randSeed": [type, steps, movement], "id": id}
		1:
			var rotation = randi() % 3
			var description
			match rotation:
				0:
					description = str("Rotate left")
				1:
					description = str("Rotate right")
				2:
					description = str("Rotate u-turn")
			return {"description": description, "randSeed": [type, rotation], "id": id}

static func cardFromInfos(infos):
	var cards = []
	for info in infos:
		cards.append(cardFromInfo(info))
	return cards

static func cardFromInfo(info):
	var card = generateCard(Seed.new(info.randSeed))
	card.description = info.description
	return card

static func generate(nCards):
	var cards = []
	for i in range(nCards):
		cards.append(generateCard(Seed.new()))
	return cards

static func createRotateLeft():
	return Card.new(
		Player.rotateAction(Player.LEFT), 
		"Rotate Left",
		ROTATE
	)

static func createRotateRight():
	return Card.new(
		Player.rotateAction(Player.RIGHT), 
		"Rotate Right",
		ROTATE
	)
	
static func createUturn():
	return Card.new(
		Player.rotateAction(Player.UTURN), 
		"U Turn",
		ROTATE
	)

static func createMove(steps):
	return MultiStepCard.new(
		Player.moveAction(Player.FORWARD, steps), 
		str("Move ", steps),
		MOVE
	)
	
static func createBackUp():
	return MultiStepCard.new(
		Player.moveAction(Player.BACKWARDS, 1),
		"Back Up",
		MOVE
	)
	
static func generateCard(randSeed):
	randomize()
	var type = randSeed.next(2)
	match(type):
		0:
			var steps = randSeed.next(2, 1)
			var movement = randSeed.next(2)
			match(movement):
				0:
					var stepActions = []
					for step in range(steps):
						stepActions.append(Player.moveStep(Player.FORWARD))
					return MultiStepCard.new(
						Sequence.new(stepActions), 
						str("Move forward ", steps, " steps"),
						MOVE)
				1:
					var stepActions = []
					for step in range(steps):
						stepActions.append(Player.moveStep(Player.BACKWARDS))
					return MultiStepCard.new(
						Sequence.new(stepActions), 
						str("Move backwards ", steps, " steps"),
						MOVE)
		1:
			var rotation = randSeed.next(3)
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

class Seed:

	var preset
	var index = 0

	func _init(preset = null):
		self.preset = preset
		if !preset:
			randomize()
	
	func next(i, offset = 0):
		if preset:
			var rand = preset[index]
			index += 1
			return rand
		return randi() % i + offset

class Card:
	extends CompositeAction
	
	signal cardStarted()
	signal cardFinished()
	
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
	
	func start():
		.start()
		emit_signal("cardStarted", self)

	func finish():
		.finish()
		emit_signal("cardFinished", self)

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