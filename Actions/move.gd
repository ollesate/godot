extends Action

class_name MoveStep
	
const LENGTH = 128.0
const STEP_DURATION = 1.0	
const SPEED = LENGTH / STEP_DURATION
var timeLeft = STEP_DURATION
var direction
var character_adjusted

func _init(direction, character_adjusted = false):
	self.direction = direction
	self.character_adjusted = character_adjusted

func act(delta):
	.act(delta)
	if (self.isFirstTime && character_adjusted):
		direction = direction.rotated(self.character.rotation)
	self.character.move_and_slide(direction * SPEED)
	if (self.character.get_slide_count() > 0):
		var collision = self.character.get_slide_collision(0)
		if (collision.collider.is_in_group("players")):
			collision.collider.move_and_slide(direction * SPEED)
	timeLeft -= delta;
	return timeLeft <= 0