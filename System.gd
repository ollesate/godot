extends Node2D

var actions = []

var isStarted = false

enum State { DEAL_CARDS, SIMULATION }
var state = -1

func _ready():
	$Network.connect("onGameStart", self, "Network_onGameStart")
	$Network.connect("onPlayerJoined", self, "Network_onPlayerJoined")
	$LobbyUI/Button.connect("pressed", self, "Lobby_onStartPressed")

func Network_onGameStart():
	isStarted = true
	$LobbyUI.hide()

func Network_onPlayerJoined(playerInfo):
	$Players.addPlayer(playerInfo)
	
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
	for netPlayer in $Network.get_children():
		netPlayer.dealCards([])
	actions.append(AlertAction.new("Player card phase"))
	actions.append(Wait.new(5))

func onSimulateGame():
	for netPlayer in $Network.get_children():
		netPlayer.getCards()
	
	var players = get_tree().get_nodes_in_group("players")
	var cards = []
	var player_cards = {}
	for player in players:
		player_cards[player] = []
		for card in player.getCards():
			player_cards[player].append(PlayerCard.new(card))
			
	var turns = Sequence.new([])
	for turn in range(5):
		var turnSequence = Sequence.new([])
		turnSequence.actions.append(AlertAction.new("Players move"))
		for player in player_cards.keys():
			if (turn < player_cards[player].size()):
				turnSequence.actions.append(player_cards[player][turn])
		
		turnSequence.actions.append(AlertAction.new("Players shoot"))
		turnSequence.actions.append(getShootAction())
		turnSequence.actions.append(AlertAction.new("Belts"))
		turnSequence.actions.append(getBeltsAction())
		turns.actions.append(turnSequence)
	
	actions.append(turns)

	for player in player_cards.keys():
		Global.onPlayerCards(player, player_cards[player])
	
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
		