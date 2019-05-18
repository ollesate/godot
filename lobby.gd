extends Node

const PORT = 1551
const MAX_PLAYERS = 4

export var isServer = false

var player_info = {}

signal onGameStart()

signal onConnected()
signal onDisconnected()
signal onConnectionFailed()
signal onServerDisconnect()

signal onPlayerJoined()

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	if (isServer):
		print("server start")
		peer.create_server(PORT, MAX_PLAYERS)
	else:
		print("client start")
		peer.create_client("127.0.0.1", PORT)
	get_tree().set_network_peer(peer)
	
	if isServer:
		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	else:
		get_tree().connect("connected_to_server", self, "_connected_ok")
		get_tree().connect("connection_failed", self, "_connected_fail")
		get_tree().connect("server_disconnected", self, "_server_disconnected")

func _player_connected(id):
	print(str("network peer connected ", id))

func _player_disconnected(id):
	print(str("network peer disconnected ", id))
	player_info.erase(id)

func _connected_ok():
	# Only called on clients, not server.
	print("connected to server")
	emit_signal("onConnected")

func _server_disconnected():
	print("server disconnected")
	emit_signal("onServerDisconnect")

func _connected_fail():
	print("connected fail")
	emit_signal("onConnectionFailed")

func join(id, name, color):
	print("try join lobby")
	rpc_id(0, "_register_player", id, name, color)

master func startGame():
	if player_info.size() > 0:
		rpc("_startGame")

remotesync func _startGame():
	emit_signal("onGameStart")

remote func _register_player(id, name, color):
	if player_info.has(id):
		return
	print(str("register player ", id))
	player_info[id] = { id = id, name = name, color = color }
	emit_signal("onPlayerJoined", player_info[id])
