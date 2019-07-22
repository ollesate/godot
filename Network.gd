extends Node

const PORT = 1551
const MAX_PLAYERS = 6

signal onConnected()
signal onConnectionFailed()
signal onServerDisconnect()

signal onPlayerConnected()
signal onPlayerDisconnected()
signal onPlayerJoined()
signal onPlayerLeft()
signal onPlayerReady()
signal onPlayerUnready()
signal onPlayerUpdateInfo()

signal onPlayerCards()
signal onCardStarted()
signal onCardFinished()
signal onStartSimulation()
signal onEndSimulation()
signal onGameStarted()

export var isServer = false

var playerInfos = {}
var cardInfos = {}
var networkId

func _ready():
	custom_multiplayer = MultiplayerAPI.new()
	custom_multiplayer.set_root_node(self)
	var peer = NetworkedMultiplayerENet.new()
	if (isServer):
		print("server start")
		peer.create_server(PORT, MAX_PLAYERS)
	else:
		print("client start")
		peer.create_client("localhost", PORT)
	custom_multiplayer.set_network_peer(peer)
	networkId = custom_multiplayer.get_network_unique_id()
	
	if isServer:
		custom_multiplayer.connect("network_peer_connected", self, "_peer_connected")
		custom_multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	else:
		custom_multiplayer.connect("connected_to_server", self, "connected_to_server")
		custom_multiplayer.connect("connection_failed", self, "_connected_fail")
		custom_multiplayer.connect("server_disconnected", self, "_server_disconnected")

func _process(delta):
	if custom_multiplayer.has_network_peer():
		custom_multiplayer.poll()

remote func playerReady():
	var id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("onPlayerReady", playerInfos[id])

remote func playerUnready():
	var id = custom_multiplayer.get_rpc_sender_id()
	emit_signal("onPlayerUnready", playerInfos[id])

remote func updateInfo(name, color):
	var id = custom_multiplayer.get_rpc_sender_id()
	var info = playerInfos[id]
	info.name = name
	info.color = color
	emit_signal("onPlayerUpdateInfo", info)

func dealCardsToPlayer(id, cardInfos):
	rpc_id(id, "dealCards", cardInfos)
	var playerInfo = playerInfos[id]
	self.cardInfos[playerInfo] = cardInfos

slave func dealCards(cardInfos):
	emit_signal("onPlayerCards", cardInfos)

slave func onCardStarted(cardInfo):
	emit_signal("onCardStarted", cardInfo)

slave func onCardFinished(cardInfo):
	emit_signal("onCardFinished", cardInfo)

remotesync func startSimulation():
	emit_signal("onStartSimulation")
	
remotesync func endSimulation():
	emit_signal("onEndSimulation")

remotesync func onGameStarted():
	emit_signal("onGameStarted")

remote func swapCards(idx1, idx2):
	var playerInfo = playerInfos[custom_multiplayer.get_rpc_sender_id()]	
	if not cardInfos.has(playerInfo):
		return
	var cards = cardInfos[playerInfo]
	var temp = cards[idx1]
	cards[idx1] = cards[idx2]
	cards[idx2] = temp

func _peer_connected(id):
	print("network peer connected ", id)
	var tempName = str("Player", custom_multiplayer.get_network_connected_peers().size())
	playerInfos[id] = PlayerInfo.new(id, tempName, Color.white)
	emit_signal("onPlayerConnected", id)
	emit_signal("onPlayerJoined", playerInfos[id])

func _peer_disconnected(id):
	var playerInfo = playerInfos[id]
	print("network peer disconnected ", playerInfo)
	playerInfos.erase(id)		
	emit_signal("onPlayerDisconnected", id)
	emit_signal("onPlayerLeft", playerInfo)

func _connected_to_server():
	# Only called on clients, not server.
	print("connected to server")
	emit_signal("onConnected")

func _server_disconnected():
	print("server disconnected")
	emit_signal("onServerDisconnect")

func _connected_fail():
	print("connected fail")
	emit_signal("onConnectionFailed")