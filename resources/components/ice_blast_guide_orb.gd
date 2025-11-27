extends Area2D
class_name IceBlastGuideOrb

# 指引光球：从 boss 位置飞向玩家位置

@onready var sprite: Sprite2D = $Sprite2D

var target_position: Vector2
var speed: float = 200.0
var on_arrive_callback: Callable
var scale_multiplier: float = 1.0  # 放大倍数，初始为1
var has_hit_player: bool = false  # 是否已经碰到玩家
var player_group_name: String = "player"  # 玩家分组名称

func setup(start_pos: Vector2, end_pos: Vector2, callback: Callable, player_group: String = "player"):
	global_position = start_pos
	target_position = end_pos
	on_arrive_callback = callback
	player_group_name = player_group
	
	# 连接碰撞信号
	area_entered.connect(_on_area_entered)
	
	# 计算飞行时间
	var distance = start_pos.distance_to(end_pos)
	var travel_time = distance / speed
	
	# 使用 Tween 平滑飞行
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "global_position", end_pos, travel_time)
	tween.tween_callback(_on_arrive)

func _on_area_entered(area: Area2D):
	# 检测是否碰到玩家
	if has_hit_player:
		return  # 已经触发过了，避免重复触发
	
	# 检查是否是玩家（通过group_name或groups判断）
	if area.has_meta("group_name") and area.get_meta("group_name") == player_group_name:
		has_hit_player = true
		_on_hit_player()
	elif player_group_name in area.get_groups():
		has_hit_player = true
		_on_hit_player()

func _on_hit_player():
	# 碰到玩家时，放大信号弹
	scale_multiplier = 3.0  # 放大3倍（可以根据需要调整）
	
	# 创建放大动画
	var scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(self, "scale", Vector2(scale_multiplier, scale_multiplier), 0.3)
	
	# 可以添加一些视觉效果，比如闪烁
	var flash_tween = create_tween()
	flash_tween.set_loops(3)
	flash_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0.5), 0.1)
	flash_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1.0), 0.1)

func _on_arrive():
	# 到达目标位置，触发回调，传递放大倍数
	if on_arrive_callback.is_valid():
		on_arrive_callback.call(target_position, scale_multiplier)
	
	# 淡出消失
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	fade_tween.tween_callback(queue_free)

