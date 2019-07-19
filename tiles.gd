class_name Tiles

static func create(name, cellPos, flipX, flipY, transposed):
	var key = cellPos
	match name:
		"Forward1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.get_node("Sprite").region_rect = getRect(0, 0)
			belt.config(flipX, flipY, transposed)
			belt.direction = modulate(Vector2.UP, flipX, flipY, transposed)
			return belt
		"Forward2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.direction = Vector2(0, -1)
			belt.get_node("Sprite").region_rect = getRect(1, 0)
			belt.config(flipX, flipY, transposed)
			belt.direction = modulate(Vector2.UP, flipX, flipY, transposed)
			return belt
		"Turn1":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 1
			belt.get_node("Sprite").region_rect = getRect(0, 1)
			belt.config(flipX, flipY, transposed)
			belt.direction = modulate(Vector2.LEFT, flipX, flipY, transposed)
			var otherVector = modulate(Vector2.UP, flipX, flipY, transposed)
			belt.rotate = rad2deg(otherVector.angle_to(belt.direction))
			return belt
		"Turn2":
			var belt = preload("res://conveyor.tscn").instance()
			belt.steps = 2
			belt.get_node("Sprite").region_rect = getRect(1, 1)
			belt.config(flipX, flipY, transposed)
			belt.direction = modulate(Vector2.RIGHT, flipX, flipY, transposed)
			var otherVector = modulate(Vector2.UP, flipX, flipY, transposed)
			belt.rotate = rad2deg(otherVector.angle_to(belt.direction))
			return belt
		"Laser1":
			var laser = preload("res://Laser.tscn").instance()
			var newLaserDir = modulate(laser.direction, flipX, flipY, transposed)
			var rotation = laser.direction.angle_to(newLaserDir)
			laser.direction = newLaserDir
			laser.rotation = rotation
			return laser
		"Laser2":
			var laser = preload("res://Laser2.tscn").instance()
			var newLaserDir = modulate(laser.direction, flipX, flipY, transposed)
			var rotation = laser.direction.angle_to(newLaserDir)
			laser.direction = newLaserDir
			laser.rotation = rotation
			return laser
		"Laser3":
			var laser = preload("res://Laser3.tscn").instance()
			var newLaserDir = modulate(laser.direction, flipX, flipY, transposed)
			var rotation = laser.direction.angle_to(newLaserDir)
			laser.direction = newLaserDir
			laser.rotation = rotation
			return laser
		"Spawns":
			var spawnPoint = preload("res://SpawnPoint.tscn").instance()
			var tileCoord = get_cell_autotile_coord(cellPos.x, cellPos.y)
			spawnPoint.index = tileCoord.x + 4 * tileCoord.y
			return spawnPoint
		"Checkpoints":
			var checkpoint = preload("res://Checkpoint.tscn").instance()
			var tileCoord = get_cell_autotile_coord(cellPos.x, cellPos.y)
			checkpoint.number = tileCoord.x + 4 * tileCoord.y
			if checkpoint.number == 0:
				checkpoint.setNext()
			checkpoints[cellPos] = checkpoint
			return checkpoint

const textureSize = 75

static func modulate(vector, flipX, flipY, transposed):
	if transposed:
		vector = Vector2(vector.y, vector.x)
	return Vector2(vector.x * -1 if flipX else vector.x, vector.y * -1 if flipY else vector.y)

static func getRect(x, y):
	return Rect2(x * textureSize, y * textureSize, textureSize, textureSize)