extends Action

class_name MoveStep
	
const LENGTH = Global.STEP_SIZE
const STEP_DURATION = Global.PLAYER_STEP_DURATION	
const SPEED = LENGTH / STEP_DURATION
var timeLeft = STEP_DURATION
var direction
var character_adjusted
var finished

func _init(direction, character_adjusted = false):
	self.direction = direction
	self.character_adjusted = character_adjusted

func act(delta):
	.act(delta)

	self.character.move_and_slide(direction * delta)
	if self.character.get_slide_count() > 0:
		pass
	return false