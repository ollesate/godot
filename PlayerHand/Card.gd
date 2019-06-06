tool
extends Control

class_name UiCard

enum {NONE, SELECTED, CONSUMED}

const TWEEN_DURATION = 0.1
const COLOR_STATES = [
	Color.black,
	Color.darkgreen,
	Color.darkred
]

export var state = NONE setget setState
var dragPosition
var title setget setTitle
var locked
var disabled

signal onPositionChanged(child, postion)
signal onDropped(child)

func _ready():
	self_modulate = Color.black

func setState(newState):
	if newState >= COLOR_STATES.size() or newState < 0:
		return
	state = newState
	self_modulate = COLOR_STATES[state]

func setTitle(title):
	title = title
	$Label.text = title
	
func setLocked(locked):
	self.locked = locked
	if dragPosition:
		dragPosition = null
		emit_signal("onDropped", self)

func setDisabled(disabled):
	self.disabled = disabled
	if disabled:
		self_modulate = Color.darkgray

func _gui_input(event):
	if (locked or disabled):
		return
	if event is InputEventMouseButton:
		if event.pressed:
			dragPosition = get_global_mouse_position() - rect_position
		else:
			dragPosition = null
			emit_signal("onDropped", self)
	if event is InputEventMouseMotion and dragPosition:
		rect_position.y = (get_global_mouse_position() - dragPosition).y
		emit_signal("onPositionChanged", self, rect_position)

func move(finalPos):
	var currentPos = rect_position
	$Tween.interpolate_property(self, "rect_position", currentPos, finalPos, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
