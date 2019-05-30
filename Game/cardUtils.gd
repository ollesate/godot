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
	return action