extends Node

class_name Network

const PORT = 9999
const MAX_PLAYERS = 6
const USE_ENET = false

signal onConnectionChanged()
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
signal onPlayerHpChanged()

enum { CONNECTED, FAILED, DISCONNECT }

export var isServer = false

var playerInfos = {}
var cardInfos = {}

func _ready():
	custom_multiplayer = MultiplayerAPI.new()
	custom_multiplayer.set_root_node(self)
	if (isServer):
		print("server start")
		var peer = startServer(PORT)
		custom_multiplayer.set_network_peer(peer)
	else:
		print("client start")
	
	if isServer:
		custom_multiplayer.connect("network_peer_connected", self, "_peer_connected")
		custom_multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
		print(IP.get_local_addresses())
	else:
		custom_multiplayer.connect("connected_to_server", self, "_connected_to_server")
		custom_multiplayer.connect("connection_failed", self, "_connected_fail")
		custom_multiplayer.connect("server_disconnected", self, "_server_disconnected")

func startClient(host, port):
	var peer
	if USE_ENET:
		peer = NetworkedMultiplayerENet.new()
		peer.create_client(host, port)
	else:
		peer = WebSocketClient.new()
		peer.connect_to_url("ws://%s:%s/" % [host, port], PoolStringArray(["demo"]), true)
	return peer

func startServer(port):
	var peer
	if USE_ENET:
		peer = NetworkedMultiplayerENet.new()
		peer.create_server(port)
	else:
		peer = WebSocketServer.new()
		peer.listen(port, PoolStringArray(["demo"]), true)
	return peer

func clientConnect(ip):
	print("client connecting to ", ip)
	var peer = startClient(ip, PORT)
	custom_multiplayer.set_network_peer(peer)

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

remote func onPlayerHpChanged(hpLeft):
	emit_signal("onPlayerHpChanged", hpLeft)

func _peer_connected(id):
	print("network peer connected ", id)
	print(IP.get_local_addresses())
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
	emit_signal("onConnectionChanged", CONNECTED)

func _server_disconnected():
	print("server disconnected")
	emit_signal("onServerDisconnect")
	emit_signal("onConnectionChanged", DISCONNECT)

func _connected_fail():
	print("connected fail")
	emit_signal("onConnectionFailed")
	emit_signal("onConnectionChanged", FAILED)