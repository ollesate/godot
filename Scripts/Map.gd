tool
extends Control

const DIZZY_HIGHWAY = "DizzyHighway"

const maps = [
	preload("res://Scenes/Map/Levels/DizzyHighway.tscn")
]

var currentMap = null
export(String, "DizzyHighway", "Other") var map = "DizzyHighway" setget setMap

func setMap(newMap):
	print("setMap", newMap)
	map = newMap
	if get_child_count() > 0:
		remove_child(get_child(0))
	match map:
		DIZZY_HIGHWAY:
			var map = maps[0].instance()
			currentMap = map
			add_child(map)
			rect_min_size = getMapSize(map)

func getMapSize(map):
	var background: TileMap = null
	for child in map.get_children():
		if child.name == "Background":
			background = child
	var rect = background.get_used_rect()
	var width = (rect.size.x - rect.position.x) * background.cell_size.x
	var height = (rect.size.y - rect.position.y) * background.cell_size.y
	return Vector2(width, height)

var holes = {}
var belts = {}
var checkpoints = {}
var lasers = {}
var spawns = {}

func _ready():
	print("current map", map)
	if currentMap == null:
		setMap(map)
	
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
	
func getSize():
	var rect = $Background.get_used_rect()
	var width = (rect.size.x - rect.position.x) * $Background.cell_size.x
	var height = (rect.size.y - rect.position.y) * $Background.cell_size.y
	return Vector2(width, height)

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
	return currentMap.get_node("Background").world_to_map(player.position)

func getWorldPos(player):
	var mapPos = getMapPos(player)
	var background = currentMap.get_node("Background")
	return background.map_to_world(mapPos) + background.cell_size / 2

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
