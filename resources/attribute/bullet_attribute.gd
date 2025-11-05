# PlaneState.gd（Godot 4.x 新语法版）
extends Resource
class_name BulletAttribute

# 1. 单个信号：携带「资源实例」和「变化的属性名」（方便外部判断）
#signal state_changed(plane_state: PlaneState, changed_prop: String)

# 2. 用 4.x 新语法给属性加 set 方法，每个属性指定对应的属性名
@export var bullet_speed: float = 200.0
#@export var fire_rate: float = 0.2  # 设计
@export var through_times: int = 0  # 穿透次数
@export var bullet_damage: float = 1.0
