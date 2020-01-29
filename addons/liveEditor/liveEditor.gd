tool
extends EditorPlugin
class_name LiveEditor

var tickDelay = 0.1
var tickTime = 0

const editedFileName = "res://save_game.dat"
const editedScriptFileName = "res://addons/liveEditor/edit_script.txt"

func _enter_tree():
	print("_enter_tree")

func _exit_tree():
	print("_exit_tree")

func _process(delta):
	tickTime -= delta
	if tickTime <= 0:
		tick()
		tickTime = tickDelay

func tick():
	if isEdited():
		update()

func update():
	var resPath = getEdited()
	if resPath:
		print("edit resource ", resPath)
		var res = ResourceLoader.load(resPath)
		var foundIndex = resPath.find_last("::")
		if foundIndex != -1:
			var scenePath = resPath.substr(0, foundIndex)
			get_editor_interface().open_scene_from_path(scenePath)
		get_editor_interface().edit_resource(res)
	
static func editScript(script: Reference):
	var path: String = script.resource_path
	print("editScript ", path)
	saveEdited(path)
	markEdited()

static func getEdited():
	var file = File.new()
	file.open(editedScriptFileName, File.READ)
	var path = file.get_as_text()
	file.close()
	if path:
		print("edit resource")
		file.open(editedScriptFileName, File.WRITE)
		file.store_string("")
		file.close()
		return path

static func saveEdited(path):
	var file = File.new()
	file.open(editedScriptFileName, File.WRITE)
	file.store_string(path)
	file.close()
	
static func markEdited():
	var file = File.new()
	file.open(editedFileName, File.WRITE)
	file.store_string("1")
	file.close()

static func isEdited():
	var file = File.new()
	file.open(editedFileName, File.READ_WRITE)
	var state = file.get_as_text()
	file.close()
	return state != null && state == "1"
