tool
extends Control

signal onSwap(idx1, idx2)

var positions = {}
var children = {}

export var locked = false setget setLocked
export var hpLeft = 5 setget setHpLeft

func _ready():
	for card in get_children():
		card.connect("onPositionChanged", self, "onChildChangedPosition")
		card.connect("onDropped", self, "onChildDropped")
		positions[card] = card.rect_position

func setCards(cardInfos):
	setLocked(false)
	for child in get_children():
		child.state = UiCard.NONE
	for index in range(cardInfos.size()):
		var info = cardInfos[index]
		get_child(index).title = info.description
		children[info.id] = get_child(index)

func setLocked(newLocked):
	locked = newLocked
	modulate.a = 0.7 if locked else 1.0
	for child in get_children():
		child.setLocked(locked)

func setHpLeft(newHpLeft):
	hpLeft = newHpLeft
	for idx in range(get_child_count()):
		print(str(idx, " set locked ", idx >= hpLeft))
		get_child(idx).setDisabled(idx >= hpLeft)

func selectCard(info):
	children[info.id].state = UiCard.SELECTED

func unselectCard(info):
	children[info.id].state = UiCard.CONSUMED

func onChildChangedPosition(child, position):
	for i in range(get_child_count()):
		var currentChild = get_child(i)
		if currentChild != child:
			continue
		var prevChild = get_child(i - 1) if i > 0 else null
		var nextChild = get_child(i + 1) if i < get_child_count() - 1 else null
		var posY = positions[currentChild].y
		
		if prevChild and currentChild.rect_position.y < prevChild.rect_position.y:
			var mid1 = currentChild.rect_position.y + currentChild.rect_size.y / 2
			swap(currentChild, prevChild)
			move_child(currentChild, i - 1)
		elif nextChild and !nextChild.disabled and currentChild.rect_position.y > nextChild.rect_position.y:
			swap(currentChild, nextChild)
			move_child(currentChild, i + 1)

func onChildDropped(child):
	child.rect_position = positions[child]
	
func swap(child1, child2):
	emit_signal("onSwap", index(child1), index(child2))
	var pos = positions[child1]
	positions[child1] = positions[child2]
	positions[child2] = pos
	child2.move(pos)
	
func index(child):
	for i in range(get_children().size()):
		if get_child(i) == child:
			return i
	return -1
