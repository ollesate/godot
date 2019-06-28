extends TileMap

const forward1 = "Forward1"
	
const textureSize = 75
	
func _ready():
	print(is_cell_x_flipped(0, 0))
	print(is_cell_y_flipped(0, 0))
	print(is_cell_transposed(0,0))
	
	for cellPos in get_used_cells():
		var cellId = get_cellv(cellPos)
		var name = tile_set.tile_get_name(cellId)
		var flipX = is_cell_x_flipped(cellPos.x, cellPos.y)
		var flipY = is_cell_y_flipped(cellPos.x, cellPos.y)
		var transposed = is_cell_transposed(cellPos.x, cellPos.y)
		var node = create(name, flipX, flipY, transposed)
		print(name)
		if node:
			add_child(node)
			set_cellv(cellPos, -1)
			node.position = map_to_world(cellPos) + Vector2(1, 1) * textureSize / 2
				
func create(name, flipX, flipY, transposed):
	get_path()
	match name:
		"Forward1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(0, 0)
			belt.config(flipX, flipY, transposed)
			return belt
		"Forward2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(1, 0)
			belt.config(flipX, flipY, transposed)
			return belt
		"Turn1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.rotate = -90
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(0, 1)
			belt.config(flipX, flipY, transposed)
			return belt
		"Turn2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.rotate = 90
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(1, 1)
			belt.config(flipX, flipY, transposed)
			return belt
			
func getRect(x, y):
	return Rect2(x * textureSize, y * textureSize, textureSize, textureSize)