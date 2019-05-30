extends Control

signal onSwap(idx1, idx2)

var positions = {}

func _ready():
	for card in get_children():
		card.connect("onPositionChanged", self, "onChildChangedPosition")
		card.connect("onDropped", self, "onChildDropped")
		positions[card] = card.rect_position
	setCard(0, "Hi")
	setCard(1, "Hi2")
	setCard(2, "Hi3")

func setCard(index, title):
	get_child(index).title = title
				
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
		elif nextChild and currentChild.rect_position.y > nextChild.rect_position.y:
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