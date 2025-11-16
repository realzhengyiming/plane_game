extends BaseStrategy
class_name UpgradeBulletThrouhTimeStrategy

@export var through_time: int =  1

func apply_upgrade(bullet_attribute: BulletAttribute):
	bullet_attribute.through_times = bullet_attribute.through_times + through_time
