extends Node2D

var actions = []

var isStarted = true

enum State { DEAL_CARDS, SIMULATION }
var state = -1

func _ready():
	$Network.connect("onGameStart", self, "Network_onGameStart")
	$Network.connect("onPlayerJoined", self, "Network_onPlayerJoined")
	$Network.connect("onPlayerDisconnected", self, "Network_onPlayerDisconnected")
	$LobbyUI/Button.connect("pressed", self, "Lobby_onStartPressed")

func Network_onGameStart():
	isStarted = true
	$LobbyUI.hide()

func Network_onPlayerJoined(playerInfo):
	$Players.addPlayer(playerInfo)
	
func Network_onPlayerDisconnected(playerInfo):
	$Players.removePlayer(playerInfo)
	
func Lobby_onStartPressed():
	$Network.startGame()

func _physics_process(delta):
	if !isStarted:
		return
	if (actions.size() == 0):
		onNextPhase()
		return
	if (actions[0].act(delta)):
		actions.remove(0)

func onNextPhase():
	state += 1
	state = state % State.size()
	match state:
		State.DEAL_CARDS:
			onDealCards()
		State.SIMULATION:
			onSimulateGame()

func onDealCards():
	$HUD/StateProgress.start("Dealing cards...", 4)
	for playerId in $Network.joinedPlayers:
		$Network.dealCardsToPlayer(playerId, CardUtils.generateCards())

	# Spawn killed players
	for playerId in $Network.joinedPlayers:
		if !$Players.players.has(playerId):
			$Players.addPlayer($Network.player_info[playerId])

	actions.append(AlertAction.new("Player card phase"))
	actions.append(Wait.new(4))

func onSimulateGame():
	$Network.startSimulation()
	
	$HUD/StateProgress.showText("Simulating game")
	var players = $Players.players
	var cards = []
	
	var playerCards = $Network.getPlayerCards()
	# Remove cars which has no token. Only useful when testing
	for id in playerCards.keys():
		if !players.has(id):
			playerCards.erase(id) 
	
	for id in playerCards.keys():
		var player = players[id]
		for card in playerCards[id]:
			card.character = player
			card.connect("onCardStarted", self, "onCardStarted")
			card.connect("onCardFinished", self, "onCardFinished")
			
	var turns = Sequence.new([])
	for turn in range(5):
		var turnSequence = Sequence.new([])
		turnSequence.actions.append(AlertAction.new("Players move"))
		for id in playerCards.keys():
			if (turn < playerCards[id].size()):
				turnSequence.actions.append(playerCards[id][turn])
		
		turnSequence.actions.append(AlertAction.new("Players shoot"))
		turnSequence.actions.append(getShootAction())
		turnSequence.actions.append(AlertAction.new("Belts"))
		turnSequence.actions.append(getBeltsAction())
		turns.actions.append(turnSequence)
	
	turns.actions.append(Wait.new(3))
	actions.append(turns)

func onCardStarted(card):
	$Network.onCardStarted(card)

func onCardFinished(card):
	$Network.onCardFinished(card)

func getBeltsAction():
	var parallell = Parallell.new([])
	var belts = get_tree().get_nodes_in_group("belts")
	for belt in belts:
		var action = belt.getAction()
		if (action != null):
			parallell.actions.append(action)
	return parallell

func getShootAction():
	var players = get_tree().get_nodes_in_group("players")
	var shootActions = []
	for player in players:
		var shoot = Shoot.new()
		shoot.character = player
		shootActions.append(shoot)
	return Parallell.new(shootActions)
		