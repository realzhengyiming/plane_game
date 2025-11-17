# PlaneState.gd（Godot 4.x 新语法版）
extends BaseAttribute
class_name PlaneAttribute

# 1. 单个信号：携带「资源实例」和「变化的属性名」（方便外部判断）
# 值改变了就会发送整个 属性值
signal state_changed(plane_state: PlaneAttribute, changed_prop: String)

# 2. 用 4.x 新语法给属性加 set 方法，每个属性指定对应的属性名
@export var move_speed: float = 300.0: set = set_move_speed
@export var max_health: int = 3: set = set_max_health
@export var current_health: int = 3: set = set_current_health


# 3. 每个属性的 set 方法（统一调用发送信号的逻辑）
func set_move_speed(new_value: float):
	if new_value == move_speed:
		return  # 值不变不发信号
	move_speed = new_value
	emit_signal("state_changed", self, "move_speed")  # 明确传递属性名

func set_max_health(new_value: int):
	if new_value == max_health:
		return
	max_health = new_value
	emit_signal("state_changed", self, "max_health")
	
	
func set_current_health(new_value: int):
	if new_value == current_health:
		return
	current_health = new_value
	emit_signal("state_changed", self, "current_health")
