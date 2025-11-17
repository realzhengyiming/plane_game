extends BaseAttribute
class_name WeaponAtribute

@export var fire_rate: float = 0.2: set = set_fire_rate

signal state_changed(state: WeaponAtribute, changed_prop: String)

func set_fire_rate(new_value: float):
	if new_value == fire_rate:
		return
	fire_rate = new_value
	emit_signal("state_changed", self, "fire_rate")
