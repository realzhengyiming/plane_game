extends BaseBulletStrategy
class_name UpgradeBulletThrouhTimeStrategy

@export var through_time: int =  1

func apply_upgrade(bullet_attribute: BaseAttribute):
	bullet_attribute.through_times = bullet_attribute.through_times + through_time
