# PlaneState.gd（Godot 4.x 新语法版）
extends Resource
class_name BulletAttribute

# 1. 单个信号：携带「资源实例」和「变化的属性名」（方便外部判断）
#signal state_changed(plane_state: PlaneState, changed_prop: String)

# 2. 用 4.x 新语法给属性加 set 方法，每个属性指定对应的属性名
@export var bullet_speed: float = 200.0 :set= set_bullet_speed
#@export var fire_rate: float = 0.2  # 设计
@export var through_times: int = 0  :set= set_through_times# 穿透次数
@export var bullet_damage: float = 1.0 :set= set_bullet_damage

# todo 属性发生改变了也要发对应的信号

signal bullet_attr_updated(updated_attr: BulletAttribute)

func set_bullet_speed(value):
	bullet_speed = value
	bullet_attr_updated.emit(self)  # 整个发出去

func set_through_times(value):
	through_times = value
	bullet_attr_updated.emit(self)

	
func set_bullet_damage(value):
	bullet_damage = value
	bullet_attr_updated.emit(self)
