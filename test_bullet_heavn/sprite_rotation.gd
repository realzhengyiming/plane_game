extends Node2D

@onready var sprite_2d: Sprite2D = $"../Sprite2D"  # 确保Sprite2D路径正确
@onready var timer: Timer = $Timer  # 若不需要timer可删除

# -------------------------- 可配置旋转参数（编辑器直接调整） --------------------------
@export var rotate_cycle_time: float = 2.0  # 旋转一圈的时间（秒），越小越快
@export var rotate_direction: int = 1  # 1=顺时针，-1=逆时针（可直接在编辑器改）
@export var rotate_ease: Tween.TransitionType = Tween.TRANS_LINEAR  # 缓动类型（默认匀速）
@export var rotate_ease_mode: Tween.EaseType = Tween.EASE_IN_OUT  # 缓动模式

# 保存Tween引用（防止重复创建）
var rotation_tween: Tween = null

func _ready() -> void:
	# 启动持续平滑旋转（直接调用，无需timer）
	start_continuous_rotation()
	
	# 若你仍需要timer做其他事（比如发射弹幕），保留这行；否则删除
	# timer.timeout.connect(rotation_sprite)


# 方案1：步进式旋转（timer触发一次转一次，可选保留）
func rotation_sprite() -> void:
	get_tree().kill_tweens_of(sprite_2d)  # 停止之前的动画
	
	var tween = get_tree().create_tween()
	tween.set_trans(rotate_ease)
	tween.set_ease(rotate_ease_mode)
	
	# 每次旋转30度（可自定义角度）
	var target_angle = sprite_2d.rotation_degrees + 30 * rotate_direction
	tween.tween_property(sprite_2d, "rotation_degrees", target_angle, 0.3)


# 方案2：无限持续平滑旋转（核心功能）
func start_continuous_rotation() -> void:
	# 先停止之前的Tween（防止重复叠加）
	if rotation_tween and rotation_tween.is_valid():
		rotation_tween.kill()
	
	# 创建新的Tween
	rotation_tween = get_tree().create_tween()
	rotation_tween.set_trans(rotate_ease)  # 应用缓动类型
	rotation_tween.set_ease(rotate_ease_mode)  # 应用缓动模式
	
	# 计算目标角度：当前角度 + 360度 × 方向（顺时针/逆时针）
	var target_angle = sprite_2d.rotation_degrees + (360 * rotate_direction)
	
	# 设置旋转动画：属性名必须正确（rotation_degrees是角度，rotation是弧度）
	rotation_tween.tween_property(
		sprite_2d, 
		"rotation_degrees", 
		target_angle, 
		rotate_cycle_time  # 旋转一圈的时间
	)
	
	# 设置无限循环（关键：让旋转一直持续）
	rotation_tween.set_loops()
	
	# 可选：循环时重置角度，避免数值过大（非必需，但更严谨）
	rotation_tween.finished.connect(_on_rotation_loop_finished)


# 循环结束后重置角度（避免rotation_degrees数值无限增大）
func _on_rotation_loop_finished() -> void:
	# 取模360，让角度始终在0-360之间
	sprite_2d.rotation_degrees = fmod(sprite_2d.rotation_degrees, 360)
	# 重新启动旋转（确保循环不中断）
	start_continuous_rotation()
