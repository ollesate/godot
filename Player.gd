class_name Player

extends KinematicBody2D

signal onHit()
signal onDestroyed()

const FORWARD = Vector2(1, 0)
const BACKWARDS = Vector2(-1, 0)

const LEFT = -90
const RIGHT = 90
const UTURN = 180

const SPEED_MOD = 1.0
const MOVE_DUR = 2 / SPEED_MOD
const ACT_WAIT = 1 / SPEED_MOD
const ROTATE_DUR = 1 / SPEED_MOD

const HP_MAX = 9

static func moveAction(movement, steps):
	var actions = []
	for i in range(steps):
		var moveStepAction = []
		var stepLeft = steps - i
		var res = load("res://Assets/icon_up.png") if movement == FORWARD else load("res://Assets/icon_down.png")
		moveStepAction.append(ChangePanelAction.new(res, stepLeft))
		moveStepAction.append(MovePlayer.new(movement, MOVE_DUR))
		moveStepAction.append(Actions.wait(ACT_WAIT))
		actions.append(Sequence.new(moveStepAction))
	actions.append(HidePanelAction.new())
	return Sequence.new(actions)
	
static func moveStep(movement):
	var actions = []
	actions.append(Actions.wait(0.25))
	actions.append(MovePlayer.new(movement, 0.25))
	return Sequence.new(actions)

static func rotateActionDur(rotation, duration):
	return RotatePlayer.new(rotation, duration)
	
static func rotateAction(rotation):
	var actions = []
	var resource
	match rotation:
		LEFT:
			resource = load("res://Assets/icon_rotate_left.png")
		RIGHT:
			resource = load("res://Assets/icon_rotate_right.png")
		UTURN:
			resource = load("res://Assets/icon_rotate_uturn.png")
	actions.append(ChangePanelAction.new(resource))
	actions.append(Actions.wait(ACT_WAIT))
	if rotation == UTURN:
		actions.append(RotatePlayer.new(rotation, ROTATE_DUR * 2))
	else:
		actions.append(RotatePlayer.new(rotation, ROTATE_DUR))
	actions.append(HidePanelAction.new())
	return Sequence.new(actions)

static func fallAction():
	return PlayerFall.new(1)

static func shootAction():
	return Shoot.new()

onready var hp = $UI/HP
onready var nameLabel = $UI/NameLabel
onready var cardPanel = $UI/Panel
onready var cardText = $UI/Panel/CenterContainer/HBox/Label
onready var cardTexture = $UI/Panel/CenterContainer/HBox/Container/Texture

var id
var playerName = "" setget setPlayerName
var defaultName
var color = Color.white setget setColor
var info setget setInfo
var hpMax = HP_MAX
var currentHp setget , getHp

var selfRotation setget , getSelfRotation

func getSelfRotation():
	return $Sprite.rotation

func setReady(isReady):
	$Sprite.isAnimating = isReady

func _ready():
	cardPanel.hide()
	add_to_group("players")
	hp.max_value = hpMax
	hp.hide()
	nameLabel.text = playerName
	for child in $UI/Cards.get_children():
		$UI/Cards.remove_child(child)

func setInfo(val: PlayerInfo):
	info = val
	setColor(info.color)
	setPlayerName(info.name)
	info.connect("onUpdate", self, "onInfoUpdate")

func onInfoUpdate(info):
	color = info.color
	playerName = info.name

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
		bullet.position = Vector2.ZERO
		print(bullet.position)
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

class ChangePanelAction:
	extends Action
	
	var textureRes
	var text
	
	func _init(textureRes, text = null):
		self.textureRes = textureRes
		self.text = text
	
	func act(delta):
		.act(delta)
		var spriteRotation = character.get_node("Sprite").rotation
		var rot = rad2deg(spriteRotation) + 90
		print("get rot ", rot)
		character.cardPanel.show()
		character.cardTexture.texture = textureRes
		character.cardTexture.rect_rotation = rot
		if text:
			character.cardText.text = str(text)
			character.cardText.show()
		else:
			character.cardText.hide()
		return true

class HidePanelAction:
	extends Action
	
	func act(delta):
		.act(delta)
		character.cardPanel.hide()
		return true