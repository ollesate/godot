class_name CardDeck

static func generateCardInfos(nrCards):
	var cardInfos = []
	for i in range(nrCards):
		var priority = generatePriority()
		cardInfos.append(createInfo(priority))
	return cardInfos

static func createInfo(priority):
	var card = getCard(priority)
	var id = Global.getId()
	return {"id": id, "priority": priority, "description": card.description}	

static func cardFromInfo(info):
	return getCard(info.priority)
	
static func infoFromCard(card):
	var id = Global.getId()
	var priority = 100
	return {"id": id, "priority": priority, "description": card.description}

static func generatePriority():
	randomize()
	return (randi() % 84 + 1) * 10

# https://boardgamegeek.com/thread/645061/need-specific-list-cards
static func getCard(priority):
	if priority < 70:
		return Cards.createUturn()
	elif priority < 430:
		if (priority / 10) % 2 == 0:
			return Cards.createRotateRight()
		else:
			return Cards.createRotateLeft()
	elif priority < 490:
		return Cards.createBackUp()
	elif priority < 670:
		return Cards.createMove(1)
	elif priority < 790:
		return Cards.createMove(2)
	elif priority <= 840:
		return Cards.createMove(3)
