tool

extends Control

export var position = Vector2(0, -120)

var labels = {}
var maxCards

func _ready():
	Global.connect("onCardStart", self, "Global_onCardStart")
	Global.connect("onCardEnd", self, "Global_onCardEnd")
	Global.connect("onPlayerCards", self, "Global_onPlayerCards")

func Global_onPlayerCards(player, playerCards):
	if $".." == player:
		labels.clear()
		for child in $Cards.get_children():
			child.free()
		for playerCard in playerCards:
			var label = Label.new()
			label.text = playerCard.description
			$Cards.add_child(label)
			$Cards.move_child(label, 0)
			labels[playerCard.card] = label
	maxCards = playerCards.size()
	updateOpacity()

func Global_onCardStart(player, card):
	if $".." == player:
		var color = labels[card].modulate
		labels[card].modulate = Color(0, 1, 0, color.a)
	
func Global_onCardEnd(player, card):
	if $".." == player:
		labels[card].free()
	updateOpacity()

func updateOpacity():
	var count = $Cards.get_child_count()
	for i in range(count):
		var card = $Cards.get_child(i)
		card.modulate.a = float(i + 1 + maxCards - count) / maxCards

func _process(delta):
	var rot = -get_parent().rotation
	set_rotation(rot)
	rect_position = position.rotated(rot)