tool
extends Node

export(NodePath) var target

func _ready():
	if not Engine.editor_hint:
		ScreenUtils.viewportFromControl(get_node(target))
