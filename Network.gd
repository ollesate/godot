extends Node

const PORT = 1551
const MAX_PLAYERS = 4

export var isServer = false

var player_info = {}
var playerCards = {}

signal onGameStart()

signal onConnected()
signal onConnectionFailed()
signal onServerDisconnect()

signal onPlayerJoined()
signal onPlayerDisconnected()
signal onPlayerCards()
signal onSelectCard()
signal onCardStarted()
signal onCardFinished()
signal onSimulationStart()

func _ready():
	if get_tree().network_peer != null:
		return
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

var joinedPlayers setget ,joinedPlayers

func joinedPlayers():
	return get_tree().get_network_connected_peers()

func _player_connected(id):
	print(str("network peer connected ", id))
	player_info[id] = {
		id = id,
		name = str("Player", get_tree().get_network_connected_peers().size()),
		color = Color.white
	}

func _player_disconnected(id):
	print(str("network peer disconnected ", player_info[id]))
	emit_signal("onPlayerDisconnected", player_info[id])
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

func joinLobby(id, name, color):
	print("join lobby")
	rpc_id(0, "_player_join_lobby", id, name, color)

master func startGame():
	if player_info.size() > 0:
		rpc("_startGame")

remotesync func _startGame():
	emit_signal("onGameStart")

remote func _player_join_lobby(id, name, color):
	player_info[id] = { id = id, name = name, color = color }
	print(str("Player join lobby ", player_info[id]))
	emit_signal("onPlayerJoined", player_info[id])
	rpc("addPlayer", player_info[id])

remotesync func addPlayer(playerInfo):
	var player = preload("res://PlayerNetwork.tscn").instance()
	player.set_name(str(playerInfo.id))
	player.info = playerInfo
	$Players.add_child(player)

func getMyPlayer():
	var id = get_tree().get_network_unique_id()
	for player in $Players.get_children():
		if player.info.id == id:
			return player

master func dealCardsToPlayer(id, cards):
	print(str("deal cards to player", id))
	playerCards[id] = cards
	var cardInfos = []
	for card in cards:
		cardInfos.append({
			description = card.description	
		})
	rpc_id(id, "dealCards", cardInfos)

slave func dealCards(cardInfos):
	print("onPlayerCards")
	emit_signal("onPlayerCards", cardInfos)
	
func swapCards(idx1, idx2):
	rpc_id(0, "playerSwapCards", idx1, idx2)

func playerSwapCards(idx1, idx2):
	var cards = playerCards[get_tree().get_rpc_sender_id()]
	var temp = cards[idx1]
	cards[idx1] = cards[idx2]
	cards[idx2] = temp

func getPlayerCards():
	return playerCards
	
master func onCardStarted(card):
	var playerId = card.character.id
	var cardIndex = playerCards[playerId].find(card)
	rpc_id(playerId, "Player_onCardStarted", cardIndex)

master func onCardFinished(card):
	var playerId = card.character.id
	var cardIndex = playerCards[playerId].find(card)
	rpc_id(playerId, "Player_onCardFinished", cardIndex)

slave func Player_onCardStarted(cardIndex):
	print(str("on select card ", cardIndex))
	emit_signal("onCardStarted", cardIndex)

slave func Player_onCardFinished(index):
	emit_signal("onCardFinished", index)

master func startSimulation():
	for id in get_tree().get_network_connected_peers():
		rpc_id(id, "Player_onSimulationStart")
		
slave func Player_onSimulationStart():
	emit_signal("onSimulationStart")
	