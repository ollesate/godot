class_name ScreenUtils

static func viewport(caller: Node, size: Vector2):
	if caller.get_parent() != caller.get_tree().root:
		return # Only allow our root node to set viewport
	setSize(size, caller.get_tree())

static func viewportFromControl(control: Control):
	var size = control.rect_size
	setSize(size, control.get_tree())

static func setSize(size: Vector2, tree: SceneTree):
	print("Set screen size ", size)
	tree.set_screen_stretch(
		SceneTree.STRETCH_MODE_2D, 
		SceneTree.STRETCH_ASPECT_KEEP_WIDTH, 
		size
	)

static func viewportMobile(caller):
	if caller.get_parent() != caller.get_tree().root:
		return # Only allow our root node to set viewport
	var width = OS.window_size.x
	var height = OS.window_size.y
	if OS.get_name() == "OSX":
		height = 1920
	var minSize = Vector2(width, height)
	caller.get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D, 
		SceneTree.STRETCH_ASPECT_KEEP_WIDTH, 
		minSize
	)

static func isRoot():
	return true
