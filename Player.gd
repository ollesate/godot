extends KinematicBody2D

signal onHit()
signal onDestroyed()
signal moveFinished()

const HP_MAX = 9

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel

var id
var playerName = ""
var color = Color.white
var hpMax = HP_MAX
var currentHp setget , getHp

func _ready():
	add_to_group("players")
	hp.max_value = hpMax
	hp.hide()
	nameLabel.text = playerName
	if color:
		nameLabel.modulate = color
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func setInfo(info):
	id = info.id
	if info.name:
		playerName = info.name
	else:
		playerName = str("Player", id)
	if info.color:
		color = info.color
	else:
		color = Color.white
	nameLabel.modulate = color
	nameLabel.text = playerName

var movePoint

func move(dir):
	if movePoint == null:
		movePoint = nextPoint(dir)
	print("pos")
	print(transform.origin)
	print(movePoint)
	print("distance")
	# print(transform.origin.distance_to(movePoint))
	print(transform.origin.dot(dir))
	print(movePoint.dot(dir))
	if transform.origin.dot(dir) < movePoint.dot(dir):
		move_and_slide(dir * 45.0)

func nextPoint(dir):
	var centerPos = transform.origin
	return centerPos + Global.STEP_SIZE * dir

func getHp():
	return hp.value

func onHit(damage):
	hp.value -= damage
	hp.show()
	emit_signal("onHit", self)	
	if hp.value <= 0:
		emit_signal("onDestroyed", self)
		queue_free()
		
class MoveForward:
	extends Action
	
	var movePoint
	var dir
	
	func _init(dir):
		self.dir = dir
	
	func act(delta):
		.act(delta)
		
		if !movePoint:
			movePoint = nextPoint(dir)
		print("pos")
		print(self.character.transform.origin)
		print(self.character.movePoint)
		print("distance")
		# print(transform.origin.distance_to(movePoint))
		print(self.character.transform.origin.dot(dir))
		print(self.character.movePoint.dot(dir))
		if self.character.transform.origin.dot(dir) < movePoint.dot(dir):
			self.character.move_and_slide(dir * 45.0)
			
	func nextPoint(dir):
		var centerPos = self.character.transform.origin
		return centerPos + Global.STEP_SIZE * dir