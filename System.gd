extends Node2D

var actions = []

func _physics_process(delta):
	if (actions.size() == 0):
		onNextPhase()
		return
	if (actions[0].act(delta)):
		actions.remove(0)

func onNextPhase():
	onStart()

func onStart():
	var players = get_tree().get_nodes_in_group("players")
	var cards = []
	var player_cards = {}
	for player in players:
		player_cards[player] = []
		for card in player.getCards():
			player_cards[player].append(card)
			
	var turns = Sequence.new([])
	for turn in range(5):
		var turnSequence = Sequence.new([])
		for player in player_cards.keys():
			if (turn < player_cards[player].size()):
				turnSequence.actions.append(player_cards[player][turn])
		turnSequence.actions.append(getBeltsAction())
		turns.actions.append(turnSequence)
	
	actions.append(turns)
	
func getBeltsAction():
	var parallell = Parallell.new([])
	var belts = get_tree().get_nodes_in_group("belts")
	for belt in belts:
		var action = belt.getAction()
		if (action != null):
			parallell.actions.append(action)
	return parallell