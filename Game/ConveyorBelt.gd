extends Area2D

var direction: Vector2

func _init():
	add_to_group("belts")
	direction = Vector2(0, -1).rotated(rotation)

func getAction():
	return MovePlayer.new(self, direction)

func getPlayer():
	for body in get_overlapping_bodies():
		if (body.is_in_group("players")):
			return body
	return null
	
class MovePlayer:
	extends Action
	
	var action
	var belt
	var direction
	
	func _init(belt, direction):
		self.belt = belt
		self.direction = direction
		
	func act(delta):
		.act(delta)
		if (self.isFirstTime):
			var player = belt.getPlayer()
			if (player != null):
				Global.alert("Belts")
				action = MoveStep.new(direction)
				action.character = player
			else:
				action = Wait.new(0)
		return action.act(delta)