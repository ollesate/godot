tool
extends CanvasItem

class_name CardLabel

enum {NONE, ACTIVE, FINISHED}
export(int) var state = NONE setget setState

func setText(text):
	$Label.text = text

func setState(newState):
	state = newState
	match(newState):
		NONE:
			modulate = Color(1, 1, 1)
		ACTIVE:
			modulate = Color(0, 1, 0)
		FINISHED:
			modulate = Color(1, 0, 0)

