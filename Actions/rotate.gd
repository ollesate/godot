extends Card

class_name Rotate

const DURATION = 1.0

const LEFT = -90
const RIGHT = 90
const UTURN = 180
const ROTATIONS = [LEFT, RIGHT, UTURN]

var duration = DURATION
var rotate_by
var start
var end
var current_dur = 0.0
var name

static func randRotation():
	return ROTATIONS[randi() % ROTATIONS.size()]

func _init(rotate_by):
	self.rotate_by = rotate_by
	if (rotate_by == UTURN):
		duration *= 2
	self.description = getText()

func getText():
	match rotate_by:
		LEFT:
			return "Rotate left"
		RIGHT:
			return "Rotate right"
		UTURN:
			return "Rotate u-turn"

func act(delta):
	.act(delta)
	
	if (self.isFirstTime):
		start = self.character.rotation_degrees
		end = start + rotate_by
	
	current_dur += delta
	
	self.character.rotation_degrees = lerp(start, end, current_dur/duration)
	return current_dur >= duration