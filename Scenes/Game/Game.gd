extends Control

signal onAllReady()
signal onAllReadyCancelled()

var playerInfos = []
var readyPlayers = []
var cardPlayerInfos = {}
var isPlaying

onready var gameUi = $GameBoard/Ui
onready var subtitle = $GameBoard/Ui/Header/Subtitle
onready var gameBoard = $GameBoard
onready var progress = $GameBoard/Ui/Header/Progress
onready var title = $GameBoard/Ui/Header/Title

func onPlayerJoined(info):
	gameBoard.addPlayer(info)
	playerInfos.append(info)
	updateReady()
	
func onPlayerLeft(info):
	gameBoard.removePlayer(info)
	playerInfos.remove(playerInfos.find(info))
	updateReady()

func onPlayerReady(info):
	readyPlayers.append(info)
	gameBoard.onPlayerReady(info)
	updateReady()
	if playerInfos.size() > 0 && playerInfos.size() == readyPlayers.size():
		emit_signal("onAllReady")

func onPlayerUnready(info):
	readyPlayers.remove(readyPlayers.find(info))
	gameBoard.onPlayerUnready(info)
	updateReady()
	if readyPlayers.size() == playerInfos.size() - 1:
		emit_signal("onAllReadyCancelled")

func clearReady():
	for info in readyPlayers:
		$GameBoard.onPlayerUnready(info)
	readyPlayers.clear()
	subtitle.text = ""

func updateReady():
	if not isPlaying:
		var text = str(readyPlayers.size(), " / ", $Network.playerInfos.size(), " ready")
		subtitle.text = text
	
func onPlayerUpdateInfo(info):
	gameBoard.updatePlayerInfo(info)

func _ready():
	#var size = gameBoard.get_node("Map").getSize()
	#ScreenUtils.viewport(self, Vector2(size.x + 800, size.y))

	$Network.connect("onPlayerJoined", self, "onPlayerJoined")
	$Network.connect("onPlayerLeft", self, "onPlayerLeft")
	$Network.connect("onPlayerReady", self, "onPlayerReady")
	$Network.connect("onPlayerUnready", self, "onPlayerUnready")
	$Network.connect("onPlayerUpdateInfo", self, "onPlayerUpdateInfo")
	
	gameBoard.connect("onTurnStart", self, "onTurnStart")
	gameBoard.connect("onPhaseStart", self, "onPhaseStart")
	gameBoard.connect("onPlayerWon", self, "onPlayerWon")
	gameBoard.connect("onPlayerHpChanged", self, "onPlayerHpChanged")
	
	title.text = "Hello"

	while true: # Play endlessly...
		progress.hide()
		title.show()
		title.text = getWaitingTitle()
		var countdown = 5
		var time = countdown
		var sleep = 0.5
		clearReady()
		while time > 0:
			if playerInfos.size() == 0 or readyPlayers.size() != playerInfos.size():
				title.text = getWaitingTitle()
				time = countdown
				yield(self, "onAllReady")
			title.text = str("Starting game in ", floor(time))
			yield(Actions.wait(sleep).perform(), "finished")
			time -= sleep
		$Network.rpc("onGameStarted")
		yield(playGame(), "completed")
		# resetGame()

func getWaitingTitle():
	var ip = IP.get_local_addresses().size()
	return "IP: %s\nWaiting for players..." % ip

func onPhaseStart(phase):
	gameUi.showToast(phase, 2)
	
func onTurnStart(turn):
	title.text = str("Turn ", turn)

func onPlayerWon(info):
	title.text = str(info.name, " wins!")
	$GameBoard.pause()

func onPlayerHpChanged(info, hpLeft):
	$Network.rpc_id(info.id, "onPlayerHpChanged", hpLeft)

func cardStarted(card):
	var cardInfo = cardPlayerInfos[card]
	$Network.rpc_id(cardInfo.player.id, "onCardStarted", cardInfo.card)
	# $GameUi/Header/Subtitle.text = str(cardInfo.player.name, "'s turn: ", cardInfo.card.description, ", ", cardInfo.card.priority)
		
func cardFinished(card):
	var cardInfo = cardPlayerInfos[card]
	$Network.rpc_id(cardInfo.player.id, "onCardFinished", cardInfo.card)

func playGame():
	print("playGame")
	
	var gameFinished = false
	
	while !gameFinished:
		cardPlayerInfos.clear()
		
		clearReady()
		# Give cards to player
		for info in playerInfos:
			var cardInfos = CardDeck.generateCardInfos(9)
			$Network.dealCardsToPlayer(info.id, cardInfos)
		
		gameUi.startCountdown(60)
		progress.show()
		title.text = "Card phase"
		updateReady()
		while not $GameBoard/Ui.finished && playerInfos.size() != readyPlayers.size():
			yield(Actions.wait(0.5).perform(), "finished")
		progress.hide()
		subtitle.text = ""

		var cardInfos = $Network.cardInfos
		var turns = []
		for turnIndex in range(5):
			var turn = []
			for playerInfo in cardInfos.keys():
				if cardInfos[playerInfo].size() > turnIndex:
					var cardInfo = cardInfos[playerInfo][turnIndex]
					var card = CardDeck.cardFromInfo(cardInfo)
					card.connect("cardStarted", self, "cardStarted")
					card.connect("cardFinished", self, "cardFinished")
					turn.append({"card": card, "playerInfo": playerInfo, "priority": cardInfo.priority})
					cardPlayerInfos[card] = {"card": cardInfo, "player": playerInfo} 
			turn.sort_custom(self, "prioritySort")
			turns.append(turn)
			print(turn)
		
		isPlaying = true		
		subtitle.text = ""
		$Network.rpc("startSimulation")
		yield(gameBoard.simulateGame(turns), "completed")
		isPlaying = false		

		gameFinished = false

	# Game is finished, wait for some time
	# Perhaps wait some player response?
	# Restart game

func prioritySort(a, b):
	return a.priority > b.priority
