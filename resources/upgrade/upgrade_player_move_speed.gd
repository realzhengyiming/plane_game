extends BasePlaneStrategy
class_name UpgradePlayerMoveSpeedStrategy

@export var increasing_speed_rate: float =  0.1

func apply_upgrade(player_attr: BaseAttribute):
	player_attr.move_speed = player_attr.move_speed * (1 + increasing_speed_rate)
