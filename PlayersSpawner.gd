extends Node2D

var playerScene = preload("res://Player.tscn")
var spawns = [Vector2(320, 320), Vector2(320, 448), Vector2(704, 448)]
var playerSpawns = {}

func _ready():
	# addPlayer({id = 123, name = "olof", color = Color(1, 0, 0)})
	pass

func addPlayer(playerInfo):
	var count = playerSpawns.size()
	playerSpawns[playerInfo] = spawns[count]
	var player = playerScene.instance()
	player.name = str(playerInfo.id)
	player.position = spawns[count]
	add_child(player)

func removePlayer(playerInfo):
	playerSpawns.erase(playerSpawns)
	for child in get_children():
		if child.name == playerSpawns.id:
			remove_child(child)