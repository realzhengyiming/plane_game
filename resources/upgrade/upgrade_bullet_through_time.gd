extends BaseStrategy
class_name UpgradeBulletThrouhTimeStrategy

@export var through_time: int =  1

func apply_upgrade(bullet: BulletAttribute):
	bullet.through_times = bullet.through_times + through_time
