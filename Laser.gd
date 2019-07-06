extends Sprite

signal finished()

var direction = Vector2.RIGHT setget setDirection 

func _ready():
	add_to_group("lasers")

func setDirection(val):
	direction = val
	$LaserEmitter.direction = val

func shoot():
	$LaserEmitter.shoot()
	yield($LaserEmitter, "finished")
	emit_signal("finished")