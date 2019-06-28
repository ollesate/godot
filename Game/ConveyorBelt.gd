extends Area2D

var steps = 1
var rotate = 0

enum TYPE {
	STRAIGHT,
	TURN
}

var move = Vector2(0, 1)

func _init():
	add_to_group("belts")
	
func config(flipX, flipY, transpose):
	$Sprite.flip_h = flipX if not transpose else flipY
	$Sprite.flip_v = flipY if not transpose else flipX
	if transpose:
		$Sprite.scale.y = -1
		$Sprite.rotate(deg2rad(90))

func getAction():
	return MovePlayer.new(self, Vector2(0, 0))

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