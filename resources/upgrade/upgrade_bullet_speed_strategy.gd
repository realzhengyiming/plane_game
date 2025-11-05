extends BaseStrategy
class_name UpgradeBulletSpeedStrategy

@export var increasing_rate: float =  0.1

func apply_upgrade(bullet: BulletAttribute):
	bullet.bullet_speed = bullet.bullet_speed * (1 + increasing_rate)
