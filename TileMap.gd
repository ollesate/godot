extends TileMap

const textureSize = 75

var belts = {}

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
		var node = create(name, cellPos, flipX, flipY, transposed)
		print(name)
		if node:
			add_child(node)
			set_cellv(cellPos, -1)
			node.position = map_to_world(cellPos) + Vector2(1, 1) * textureSize / 2
	
	yield(Actions.wait(0.5).perform(), "finished")
	perform()
				
func create(name, cellPos, flipX, flipY, transposed):
	var key = cellPos
	match name:
		"Forward1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.straight = true
			belt.direction = Vector2(0, -1)
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(0, 0)
			belt.config(flipX, flipY, transposed)
			if transposed:
				belt.direction = Vector2(belt.direction.y, belt.direction.x)
			belt.direction = Vector2(belt.direction.x * -1 if flipX else belt.direction.x, belt.direction.y * -1 if flipY else belt.direction.y)
			belts[key] = belt
			return belt
		"Forward2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.straight = true
			belt.direction = Vector2(0, -1)
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(1, 0)
			belt.config(flipX, flipY, transposed)
			if transposed:
				belt.direction = Vector2(belt.direction.y, belt.direction.x)
			belt.direction = Vector2(belt.direction.x * -1 if flipX else belt.direction.x, belt.direction.y * -1 if flipY else belt.direction.y)
			belts[key] = belt
			return belt
		"Turn1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.direction = Vector2(-1, 0)
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(0, 1)
			belt.config(flipX, flipY, transposed)
			if transposed:
				belt.direction = Vector2(belt.direction.y, belt.direction.x)
			belt.direction = Vector2(belt.direction.x * -1 if flipX else belt.direction.x, belt.direction.y * -1 if flipY else belt.direction.y)
			var up = Vector2(0, -1)
			if transposed:
				up = Vector2(up.y, up.x)
			up = Vector2(up.x * -1 if flipX else up.x, up.y * -1 if flipY else up.y)
			belt.rotate = rad2deg(up.angle_to(belt.direction))
			belts[key] = belt
			return belt
		"Turn2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.direction = Vector2(1, 0)
			belt.get_node("Sprite").region_enabled = true
			belt.get_node("Sprite").region_rect = getRect(1, 1)
			belt.config(flipX, flipY, transposed)
			if transposed:
				belt.direction = Vector2(belt.direction.y, belt.direction.x)
			belt.direction = Vector2(belt.direction.x * -1 if flipX else belt.direction.x, belt.direction.y * -1 if flipY else belt.direction.y)
			var up = Vector2(0, -1)
			if transposed:
				up = Vector2(up.y, up.x)
			up = Vector2(up.x * -1 if flipX else up.x, up.y * -1 if flipY else up.y)
			belt.rotate = rad2deg(up.angle_to(belt.direction))
			belts[key] = belt
			return belt
			
func getRect(x, y):
	return Rect2(x * textureSize, y * textureSize, textureSize, textureSize)

func perform():
	for i in range(5):
		yield(getBeltAction(1).perform(), "finished")
		yield(Actions.wait(.5).perform(), "finished")

func getBeltAction(step):
	var players = get_tree().get_nodes_in_group("players")
	var actions = []
	for player in players:
		var cellPos = world_to_map(player.position)
		if belts.has(cellPos):
			var belt = belts[cellPos]
			if belt.steps >= step:
				var next = cellPos + belt.direction
				if belts.has(next):
					var nextBelt = belts[next]
					if nextBelt.rotate != 0:
						actions.append(RotateAction.new(nextBelt.rotate, 1.0).with(player))
				actions.append(BeltMove.new(belt).with(player))
	return Parallell.new(actions)

class RotateAction:
	extends Action
	
	var rotation
	var duration
	
	func _init(rotation, duration):
		self.rotation = deg2rad(rotation)
		self.duration = duration
	
	func act(delta):
		duration -= delta
		character.rotate(rotation * delta)
		return duration <= 0

class BeltMove:
	extends ActionMove
	
	const DURATION = 1.0
	const STEP_SIZE = 75.0
	
	var belt
	
	func _init(belt).(belt.direction, DURATION, STEP_SIZE / DURATION):
		self.belt = belt
	
	func start():
		belt.start()
		character.collision_mask = 2 
	
	func finish():
		belt.stop()
		character.collision_mask = 1
		
	func act(delta):
		if character.get_slide_count() > 0:
			return true
		return .act(delta)