extends Card

class_name Shoot
	
var bulletScene = preload("res://Game/Bullet.tscn")

var isHit = false

func act(delta):
	.act(delta)
	if self.isFirstTime:
		# Shoot and wait for it to hit something...
		var bullet = bulletScene.instance()
		bullet.rotation = self.character.rotation
		bullet.connect("onHit", self, "onBulletHit")
		bullet.playerOwner = self.character
		self.character.add_child(bullet)
	return isHit

func onBulletHit():
	isHit = true