extends Node2D

var holes = {}
var belts = {}
var checkpoints = {}
var lasers = {}
var spawns = {}

func _ready():
	for map in get_tree().get_nodes_in_group("backgroundTilemaps"):
		for pos in map.holes.keys():
			holes[pos] = map.holes[pos]
	for map in get_tree().get_nodes_in_group("foregroundTilemaps"):
		for pos in map.belts.keys():
			belts[pos] = map.belts[pos]
		for pos in map.checkpoints.keys():
			checkpoints[pos] = map.checkpoints[pos]
		for pos in map.lasers.keys():
			lasers[pos] = map.lasers[pos]
		for pos in map.spawns.keys():
			spawns[pos] = map.spawns[pos]
	var rect = $Background.get_used_rect()
	var width = (rect.size.x - rect.position.x) * $Background.cell_size.x
	var height = (rect.size.y - rect.position.y) * $Background.cell_size.y
	var aspect = Vector2(width, height)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP_WIDTH, aspect)
	

func getSpawn(number):
	for spawn in spawns.values():
		if spawn.index == number:
			return spawn
	return null
	
func getCheckpoint(player):
	var mapPos = getMapPos(player)
	return checkpoints[mapPos] if checkpoints.has(mapPos) else null

func getCheckpointIndexed(index):
	for checkpoint in checkpoints.values():
		if checkpoint.number == index:
			return checkpoint
	return null

func getPlayersInHole():
	var players = []
	for player in get_tree().get_nodes_in_group("players"):
		var cellPos = getMapPos(player)
		if holes.has(cellPos):
			players.append(player)
	return players

func getMapPos(player):
	return $Background.world_to_map(player.position)

func getWorldPos(player):
	var mapPos = getMapPos(player)
	return $Background.map_to_world(mapPos) + $Background.cell_size / 2
	

func getBeltAction(step):
	var players = get_tree().get_nodes_in_group("players")
	var actions = []
	for player in players:
		var cellPos = getMapPos(player)
		if belts.has(cellPos):
			var belt = belts[cellPos]
			if belt.steps >= step:
				var next = cellPos + belt.direction
				if belts.has(next):
					var nextBelt = belts[next]
					if nextBelt.rotate != 0:
						actions.append(Player.rotateActionDur(nextBelt.rotate, 1.0).with(player))
						# actions.append(RotateAction.new(nextBelt.rotate, 1.0).with(player))
				actions.append(BeltMove.new(belt).with(player))
	return Parallell.new(actions)

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