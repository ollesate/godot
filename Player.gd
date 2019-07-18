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
		actions.append(MovePlayer.new(movement, 0.25))
		actions.append(Actions.wait(0.25))
	return Sequence.new(actions)
	
static func moveStep(movement):
	var actions = []
	actions.append(Actions.wait(0.25))
	actions.append(MovePlayer.new(movement, 0.25))
	return Sequence.new(actions)
	
static func rotateAction(rotation):
	var actions = []
	actions.append(Actions.wait(0.25))
	if rotation == UTURN:
		actions.append(RotatePlayer.new(rotation, 0.5))
	else:
		actions.append(RotatePlayer.new(rotation, 0.25))
	return Sequence.new(actions)

static func fallAction():
	return PlayerFall.new(1)

static func shootAction():
	return Shoot.new()

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel

var id
var playerName = "" setget setPlayerName
var defaultName
var color = Color.white setget setColor
var hpMax = HP_MAX
var currentHp setget , getHp

var selfRotation setget , getSelfRotation

func getSelfRotation():
	return $Sprite.rotation

func setReady(isReady):
	$Sprite.isAnimating = isReady

func _ready():
	add_to_group("players")
	hp.max_value = hpMax
	hp.hide()
	nameLabel.text = playerName
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func setColor(val):
	color = val if val != null else Color.white
	$Sprite.self_modulate = color

func setPlayerName(val):
	if not defaultName:
		defaultName = val
	playerName = val if val else defaultName
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
	var duration
	
	func _init(direction, duration):
		self.direction = direction
		self.duration = duration
	
	func start():
		moveAction = ActionMove.new(direction.rotated(character.selfRotation), duration, 75).with(character)
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
		bullet.playerOwner = self.character
		bullet.position = self.character.get_node("Sprite/Nozzle").position
		self.character.get_node("Sprite/Nozzle").add_child(bullet)
		yield(bullet, "onHit")
		isHit = true
	
	func act(delta):
		return isHit

class RotatePlayer:
	extends Action
	
	var rotationSpeed
	var duration
	
	func _init(rotation, duration):
		self.rotationSpeed = deg2rad(rotation) / duration
		self.duration = duration
	
	func act(delta):
		duration -= delta
		character.get_node("Sprite").rotate(rotationSpeed * delta)
		return duration <= 0