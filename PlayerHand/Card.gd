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

signal onPositionChanged(child, postion)
signal onDropped(child)

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

func _gui_input(event):
	if (locked):
		return
	if event is InputEventMouseButton:
		if event.pressed:
			dragPosition = get_global_mouse_position() - rect_global_position
		else:
			dragPosition = null
			emit_signal("onDropped", self)
	if event is InputEventMouseMotion and dragPosition:
		rect_global_position.y = (get_global_mouse_position() - dragPosition).y
		emit_signal("onPositionChanged", self, rect_global_position)

func move(finalPos):
	var currentPos = rect_global_position
	$Tween.interpolate_property(self, "rect_global_position", currentPos, finalPos, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
