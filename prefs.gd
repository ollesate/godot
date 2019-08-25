class_name Prefs

const SAVE_PATH = "res://prefs.json"

static func save(key, value):
	var file = File.new()
	file.open(SAVE_PATH, File.WRITE_READ)
	var data = file.get_var(false)
	if not data:
		data = {}
	data[key] = value
	file.store_var(data, false)
	file.close()

static func load(key):
	var file = File.new()
	if not file.file_exists(SAVE_PATH):
		return null
	file.open(SAVE_PATH, File.READ)
	var data = file.get_var(false)
	file.close()
	return data[key] if data.has(key) else null
		