extends Node2D

signal finished()

const REACH = 10000

var direction = Vector2.RIGHT

func _ready():
	$Laser.default_color.a = 0.3
	$Tween.connect("tween_all_completed", self, "animFinished")	

func shootAnim():
	var from = $Laser.default_color
	var to = Color(from)
	to.a = 1.0
	var duration = 1.5 / Global.SPEED_MODIFIER
	$Tween.interpolate_property(
		$Laser, 
		"default_color", 
		from, 
		to, 
		duration, 
		Tween.TRANS_EXPO, 
		Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		$Laser, 
		"scale", 
		Vector2(1, .7), 
		Vector2(1, 1.5), 
		duration, 
		Tween.TRANS_EXPO, 
		Tween.EASE_IN_OUT
	)
	$Tween.start()

func animFinished():
	$Laser.scale = Vector2(1, 1)
	$Laser.default_color.a = 0.3
	var laserIntersect = getLaserIntersect()
	if laserIntersect:
		if laserIntersect.collider.is_in_group("players"):
			# laserIntersect.collider.onHit(1)
			pass
	emit_signal("finished")
	
func shoot():
	shootAnim()

func _process(delta):
	var laserIntersect = getLaserIntersect()
	if laserIntersect:
		$Laser.points[1] = to_local(laserIntersect.position)
	else:
		$Laser.points[1] = $Laser.points[0] + direction * REACH

func getLaserIntersect():
	var spaceState = get_world_2d().direct_space_state
	return spaceState.intersect_ray(
		global_position, 
		global_position + direction * REACH
	)

func getAction():
	return Sequence.new(
		[LaserAction.new(self), Wait.new(Global.LASER_DURATION)]
	)

class LaserAction:
	extends Action
	
	var laser
	var isFinished
	
	func _init(laser):
		self.laser = laser
		laser.connect("onShootFinished", self, "finished")
	
	func act(delta):
		.act(delta)
		if self.isFirstTime:
			laser.shoot()
		return isFinished
	
	func finished():
		isFinished = true
		