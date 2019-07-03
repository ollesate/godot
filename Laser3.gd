extends Sprite

signal finished()

var direction = Vector2.RIGHT setget setDirection 

func _ready():
	add_to_group("lasers")

func setDirection(val):
	direction = val
	$LaserEmitter.direction = val
	$LaserEmitter2.direction = val
	$LaserEmitter3.direction = val

func shoot():
	$LaserEmitter.shoot()
	$LaserEmitter2.shoot()
	$LaserEmitter3.shoot()
	yield($LaserEmitter, "finished")
	yield($LaserEmitter2, "finished")
	yield($LaserEmitter3, "finished")
	emit_signal("finished")
