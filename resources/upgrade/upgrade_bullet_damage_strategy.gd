extends BaseStrategy
class_name UpgradeBulletDamageStrategy

@export var increasing_damage: float =  0.5

func apply_upgrade(bullet_attribute: BulletAttribute):
	bullet_attribute.bullet_damage = bullet_attribute.bullet_damage + increasing_damage
