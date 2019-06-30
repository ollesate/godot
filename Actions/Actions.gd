class_name Actions

static func move(dir, duration, speed = 100.0):
	return Move.new(dir, duration, speed)

static func moveLength(dir, length, duration):
	return Move.new(dir, duration, length / duration)

static func wait(duration):
	return Wait.new(duration)

class Move:
	extends Action
	
	var speed
	var direction
	var duration
	
	func _init(direction, duration, speed):
		self.direction = direction
		self.speed = speed
		self.duration = duration
		
	func act(delta):
		.act(delta)
		if not character:
			return true
		character.move_and_slide(direction * speed)
		duration -= delta
		if duration <= 0:
			return true