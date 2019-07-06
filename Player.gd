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
	
static func moveStep(movement):
	var actions = []
	actions.append(Actions.wait(1))
	actions.append(MovePlayer.new(movement))
	return Sequence.new(actions)
	
static func rotateAction(rotation):
	if rotation == UTURN:
		return RotateAction.new(rotation, 1)
	return RotateAction.new(rotation, 0.5)

static func fallAction():
	return PlayerFall.new(1)

static func shootAction():
	return Shoot.new()

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel

var id
var playerName = "" setget setPlayerName
var color = Color.white setget setColor
var hpMax = HP_MAX
var currentHp setget , getHp

func _ready():
	add_to_group("players")
	hp.max_value = hpMax
	hp.hide()
	nameLabel.text = playerName
	nameLabel.modulate = color
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func setColor(val):
	color = val if val != null else Color.white
	nameLabel.modulate = color
	modulate = color

func setPlayerName(val):
	playerName = val if val else ""
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

class PlayerFall:
	extends CompositeAction

	var action

	func _init(fallDuration):
		action = ScaleAction.new(0, fallDuration)
		actions = [action]
	
	func start():
		.start()
		# Emit in advance stops all actions on this while animating
		character.emit_signal("onDestroyed", character)
		
	func act(delta):
		if action.act(delta):
			character.free()
			return true
		return false

class Shoot:
	extends Action
	
	var isHit = false

	func start():
		# Shoot and wait for it to hit something...
		var bullet = preload("res://Game/Bullet.tscn").instance()
		bullet.rotation = self.character.rotation
		bullet.playerOwner = self.character
		bullet.position = self.character.get_node("Nozzle").position
		self.character.add_child(bullet)
		yield(bullet, "onHit")
		isHit = true
	
	func act(delta):
		return isHit