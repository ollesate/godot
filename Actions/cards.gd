class_name Cards

static func generate(nCards):
	var type = randi() % 2
	match(type):
		0:
			var steps = randi() % 4 + 1
			var movement = randi() % 2
			match(movement):
				0:
					return Card.new(
						Player.moveAction(Player.FORWARD, steps), 
						str("Move forward ", steps, " steps"))
				1:
					return Card.new(
						Player.moveAction(Player.BACKWARDS, steps), 
						str("Move backwards ", steps, " steps"))
		1:
			var rotation = randi() % 3
			match(rotation):
				0:
					return Card.new(
						Player.rotateAction(Player.LEFT), 
						"Rotate left")
				1:
					return Card.new(
						Player.rotateAction(Player.RIGHT), 
						"Rotate right")
				2:
					return Card.new(
						Player.rotateAction(Player.UTURN), 
						"Rotate uturn")

class Card:
	extends CompositeAction
	
	var description
	
	func _init(action, description).([action]):
		self.description = description