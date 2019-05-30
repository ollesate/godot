extends Control

const TWEEN_DURATION = 0.1

var dragPosition
var title setget setTitle

signal onPositionChanged(child, postion)
signal onDropped(child)

func setTitle(title):
	title = title
	$Label.text = title

func _gui_input(event):
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
