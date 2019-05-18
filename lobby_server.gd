extends "res://lobby.gd"

const SPAWN_1 = Vector2(320, 320)

var playerScene = preload("res://Player.tscn")

func _on_Button_pressed():
	print ("hello")

remote func register_player(id, info):
	print ("hello player registered")