class_name Player

extends KinematicBody2D

signal onHit()
signal onDestroyed()

const FORWARD = Vector2(1, 0)
const BACKWARDS = Vector2(-1, 0)

const LEFT = -90
const RIGHT = 90
const UTURN = 180

const HP_MAX = 9

static func moveAction(movement, steps):
	var actions = []
	for i in range(steps):
		actions.append(MovePlayer.new(movement))
		actions.append(Actions.wait(1))
	return Sequence.new(actions)
	
static func rotateAction(rotation):
	if rotation == UTURN:
		return RotateAction.new(rotation, 2)
	return RotateAction.new(rotation, 1)

static func shootAction():
	return Shoot.new()

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

func getHp():
	return hp.value

func onHit(damage):
	hp.value -= damage
	hp.show()
	emit_signal("onHit", self)	
	if hp.value <= 0:
		emit_signal("onDestroyed", self)
		queue_free()
		
class MovePlayer:
	extends CompositeAction

	var moveAction
	var direction
	
	func _init(direction):
		self.direction = direction
	
	func start():
		moveAction = ActionMove.new(direction, 1, 75).with(character)
		character.get_node("Sprite").isAnimating = true
		
	func finish():
		character.get_node("Sprite").isAnimating = false
	
	func act(delta):
		if moveAction.act(delta):
			return true
		if character.get_slide_count() > 0:
			var collider = character.get_slide_collision(0).collider
			if collider.is_in_group("players"):
				var player: KinematicBody2D = collider
				player.move_and_slide(moveAction.velocity)

class Shoot:
	extends Action
	
	var isHit = false

	func start():
		# Shoot and wait for it to hit something...
		var bullet = preload("res://Game/Bullet.tscn").instance()
		bullet.rotation = self.character.rotation
		bullet.playerOwner = self.character
		self.character.add_child(bullet)
		yield(bullet, "onHit")
		isHit = true
	
	func act(delta):
		return isHit