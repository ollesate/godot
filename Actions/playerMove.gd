class_name PlayerMove
	
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