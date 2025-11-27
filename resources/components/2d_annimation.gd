extends Node
class_name Animation2DComponent

# 在编辑器中配置：选择要应用动画的目标节点
@export_node_path("Node2D") var owner_node_path: NodePath

# 动画参数（可在编辑器中调整）
@export var animation_name: String = "breathing"
@export var animation_duration: float = 2.0
@export var scale_amount: float = 0.05  # 缩放幅度（5%）
@export var enable_position_sway: bool = false  # 是否启用位置摇摆
@export var sway_amount: Vector2 = Vector2(2, 0)  # 摇摆幅度
@export var auto_start: bool = true  # 是否自动开始

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var owner_node: Node2D

func _ready():
	# 获取目标节点
	owner_node = get_node_or_null(owner_node_path) as Node2D
	
	if not owner_node:
		push_error("Animation2DComponent: owner_node 未找到，路径: " + str(owner_node_path))
		return
	
	if not animation_player:
		push_error("Animation2DComponent: AnimationPlayer 节点未找到")
		return
	
	# 创建动画
	create_animation()
	
	# 如果设置了自动开始，则播放
	if auto_start:
		play_animation()

# 创建动画
func create_animation():
	if not owner_node or not animation_player:
		return
	
	var animation = Animation.new()
	animation.length = animation_duration
	animation.loop_mode = Animation.LOOP_LINEAR
	
	# 保存原始值
	var original_scale = owner_node.scale
	var original_position = owner_node.position
	
	# 计算路径
	var base_path = animation_player.get_path_to(owner_node)
	
	# 1. Scale 轨道（缩放）
	var scale_track = animation.add_track(Animation.TYPE_VALUE)
	var scale_path = NodePath(str(base_path) + ":scale")
	animation.track_set_path(scale_track, scale_path)
	
	animation.track_insert_key(scale_track, 0.0, original_scale)
	animation.track_insert_key(scale_track, animation_duration / 2.0, original_scale * (1.0 + scale_amount))
	animation.track_insert_key(scale_track, animation_duration, original_scale)
	
	# 设置平滑过渡
	for i in range(animation.track_get_key_count(scale_track)):
		animation.track_set_key_transition(scale_track, i, 1.0)
	
	# 2. Position 轨道（可选，位置摇摆）
	if enable_position_sway:
		var pos_track = animation.add_track(Animation.TYPE_VALUE)
		var pos_path = NodePath(str(base_path) + ":position")
		animation.track_set_path(pos_track, pos_path)
		
		animation.track_insert_key(pos_track, 0.0, original_position)
		animation.track_insert_key(pos_track, animation_duration / 3.0, original_position - sway_amount)
		animation.track_insert_key(pos_track, animation_duration * 2.0 / 3.0, original_position + sway_amount)
		animation.track_insert_key(pos_track, animation_duration, original_position)
		
		for i in range(animation.track_get_key_count(pos_track)):
			animation.track_set_key_transition(pos_track, i, 1.0)
	
	# Godot 4.x 方式：使用 AnimationLibrary
	# 创建或获取默认的动画库
	var library_name = "default"
	var library: AnimationLibrary
	
	if animation_player.has_animation_library(library_name):
		library = animation_player.get_animation_library(library_name)
	else:
		library = AnimationLibrary.new()
		animation_player.add_animation_library(library_name, library)
	
	# 如果动画已存在，先移除
	if library.has_animation(animation_name):
		library.remove_animation(animation_name)
	
	# 添加动画到 library
	library.add_animation(animation_name, animation)
	
	print("Animation2DComponent: 动画已创建 - ", animation_name, " 作用在: ", owner_node.name)

# 播放动画
func play_animation():
	if not animation_player:
		return
	
	# 检查动画是否存在（在默认库中）
	var library_name = "default"
	if animation_player.has_animation_library(library_name):
		var library = animation_player.get_animation_library(library_name)
		if library.has_animation(animation_name):
			animation_player.play(animation_name)
			print("Animation2DComponent: 开始播放动画 - ", animation_name)
			return
	
	push_error("Animation2DComponent: 动画不存在 - " + animation_name)

# 停止动画
func stop_animation():
	if animation_player and animation_player.is_playing():
		animation_player.stop()
		print("Animation2DComponent: 停止动画")

# 暂停动画
func pause_animation():
	if animation_player and animation_player.is_playing():
		animation_player.pause()
		print("Animation2DComponent: 暂停动画")

# 恢复动画
func resume_animation():
	if animation_player:
		animation_player.play()
		print("Animation2DComponent: 恢复动画")
