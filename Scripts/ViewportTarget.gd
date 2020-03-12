tool
extends Node

export(NodePath) var target

func _ready():
	setScreenSize()

func setScreenSize():
	if not Engine.editor_hint:
		if target:
			ScreenUtils.viewportFromControl(get_node(target))

func _on_Map_item_rect_changed():
	setScreenSize()
