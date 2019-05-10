extends KinematicBody2D

signal onHit

const SPEED = 500
const ROTATION_SPEED = 20.0
const MAX_TIME = 4.0

var direction
var duration = MAX_TIME
var playerOwner

func _ready():
	direction = Vector2(0, -1).rotated(rotation)
	print (direction)
	
func _physics_process(delta):
	rotate(deg2rad(ROTATION_SPEED))
	move_and_slide(direction * SPEED)
	duration -= delta
	if get_slide_count() > 0:
		var collider = get_slide_collision(0).collider
		if (collider != get_parent() && collider.is_in_group("players")):
			if (playerOwner != collider):
				collider.onHit(1)
		emit_signal("onHit")
		free()
	elif duration < 0:
		emit_signal("onHit")
		free()