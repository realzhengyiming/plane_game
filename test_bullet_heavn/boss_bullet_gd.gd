extends Area2D
@onready var spwan_bullet_mark: Marker2D = $Marker2D
@export var bullet_scene: PackedScene
@onready var shoot_timer: Timer = $shoot_timer
@onready var rotation_timer: Timer = $rotation_timer
var direction: Vector2 = Vector2.DOWN
@export var group_name:String = UpgradeConfig.IS_ENEMY
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var root: CompoundState = $StateChart/root
@onready var state_chart: StateChart = $StateChart
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

@export var max_health:float
var hp: float : set = set_hp
var used_flag: bool = false
var state2_flag: bool = false

var first_state_timer = Timer.new()  # 先创建，但是不启动

func set_hp(value):
	hp = value
	progress_bar.value = value
	
	if hp <= max_health / 4:
		if state2_flag != true:
			state_chart.send_event("to_skill_super")
			print("to_skill_super")
			state2_flag = true
	
	if hp <= max_health / 2:
		if used_flag != true:
			state_chart.send_event("to_无敌状态")
			print("发送信号，to_无敌状态")
			used_flag = true
			
	if hp <=0:
		print("boss 死了")
		queue_free()

func _ready() -> void:
	progress_bar.max_value = max_health
	hp = max_health
	
# boss 的攻击还是要设计一下的

func get_player_position():
	# 游戏开始时查找一次玩家并缓存引用
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player = players[0]
		return player.global_position
	return

func rota_direction():
	# 按照每0.5s旋转多少弧
	print("旋转了角度")
	direction = direction.rotated(deg_to_rad(20))  # 还是说直接自己转了，


func fire_bullet_heavn() -> void:
	#if UpgradeConfig.get_top_level_active_states(root) != "hp_half":
		#return
	print("boss进来发射了")
	if not bullet_scene:
		return
	var bullet = bullet_scene.instantiate()
	if bullet.has_method("setup"):
		#get_parent().get_parent().add_child(bullet)
		get_tree().current_scene.get_parent().add_child(bullet)
		var bullet_position = spwan_bullet_mark.global_position #- Vector2(0, 50)
		#var bullet_position = position - Vdector2(0, 50)
		print("direction", direction)
		bullet.setup(bullet_position, direction, group_name)
		bullet.wave_amplitude = 50
		bullet.wave_frequency = 0.5
		bullet.bullet_state.bullet_speed = 100

func fire_shot_player(dir):
	var bullet = bullet_scene.instantiate()

	get_tree().current_scene.get_parent().add_child(bullet)
	var bullet_position = spwan_bullet_mark.global_position #- Vector2(0, 50)
	print("direction", direction)
	bullet.setup(bullet_position, dir, group_name)
	bullet.scale = Vector2(3, 3)
	bullet.wave_amplitude = 1
	bullet.wave_frequency = 1


func _on_area_entered(area: Area2D) -> void:
	var current_state = UpgradeConfig.get_top_level_active_states(root)
	if current_state == "无敌状态":
		return   # 直接跳过
		# 被子弹打了，就扣血 半血就发疯
	pass # Replace with function body.
	if area.is_in_group("player"):
		print("玩家的子弹进来了")
		hp -= area.bullet_state.bullet_damage


func _on_hp_full_state_entered() -> void:
	pass # Replace with function body.
	print("现在是血量第一阶段")
	first_state_timer.wait_time = 1
	first_state_timer.autostart = true
	first_state_timer.timeout.connect(shot_player)
	add_child(first_state_timer)
	
# 第一阶段结束
func _on_hp_full_state_exited() -> void:
	pass # Replace with function body
	remove_child(first_state_timer)
	
func shot_player():
	print("正在攻击玩家")
	var player_position = get_player_position()
	if player_position != null:
		var vector2_dir = player_position - spwan_bullet_mark.global_position  # 子弹生成的位置，而不是boss的位置
		fire_shot_player(vector2_dir.normalized())
	else:
		print("没有找到玩家")

func _on_无敌状态_state_entered() -> void:
	# todo 配置几秒的无敌
	collision_polygon_2d.disabled = true
	# 增加shadow 闪烁抖动啥的
	
	# 播放动画
	print("正在无敌状态")
	var timer = Timer.new()
	timer.wait_time = 1
	timer.autostart = true
	add_child(timer)
	
	# 简单闪烁示例（也可以用 AnimationPlayer）
	var tween = create_tween().set_loops(4)
	tween.tween_property(self, "modulate:a", 0.3, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1)

	timer.timeout.connect(invincible_timeout)

	
func invincible_timeout():
	collision_polygon_2d.disabled = false
	print("无敌状态解除")	
	modulate.a = 1.0
	# 看血量分配
	if hp <= max_health * 1/3:
		state_chart.send_event("to_hp_final")  # 有点不好使的是，这个string 竟然不能直接引用枚举值
	elif hp <= max_health * 2/3:
		state_chart.send_event("to_skill_super")


func _on_hp_half_state_entered() -> void:
	pass # Replace with function body.
	shoot_timer.autostart = true
	rotation_timer.autostart = true
	
	shoot_timer.timeout.connect(fire_bullet_heavn)
	rotation_timer.timeout.connect(rota_direction)
	
	# 3 种不同的状态切换
	
# 冰魂大招相关资源
@export var guide_orb_scene: PackedScene  # 指引光球场景
@export var indicator_scene: PackedScene   # 范围指示器场景
@export var ice_blast_scene: PackedScene   # 真正的冰球场景


func ice_skill_timer_setup():
	
	print("进入了大招模式")
	var ice_timer = Timer.new()
	ice_timer.wait_time = 2
	ice_timer.autostart = true
	add_child(ice_timer)
	
	ice_timer.timeout.connect(ice_skill_super)
	

func ice_skill_super():
	# 冰魂大：三阶段效果
	# 1. 指引光球飞行到玩家位置
	# 2. 在玩家位置显示范围指示器
	# 3. 延迟后发射真正的快速冰球
	if hp < max_health * 1 / 3:
		state_chart.send_event("to_无敌状态")
	else:
		var player_position = get_player_position()
		if not player_position:
			print("冰魂大：无法获取玩家位置")
			return
		var start_position = spwan_bullet_mark.global_position
		# 阶段1：创建指引光球
		create_guide_orb(start_position, player_position)

func create_guide_orb(start_pos: Vector2, target_pos: Vector2):
	# 如果有场景，使用场景；否则用代码创建
	if guide_orb_scene:
		var orb = guide_orb_scene.instantiate()
		get_tree().current_scene.get_parent().add_child(orb)
		if orb.has_method("setup"):
			# 获取玩家分组名称
			var player_group = UpgradeConfig.IS_PLAYER
			orb.setup(start_pos, target_pos, _on_guide_orb_arrive, player_group)
	else:
		# 代码创建简单的指引光球
		var orb = create_simple_guide_orb(start_pos, target_pos, 10)

func create_simple_guide_orb(start_pos: Vector2, target_pos: Vector2, scale: float):
	# 创建一个简单的指引光球（如果没有场景）
	var orb = Area2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = load("res://snowball_atlas_texture.tres") # 使用默认图标
	sprite.modulate = Color(0.5, 0.8, 1.0, 0.8)  # 蓝色半透明
	sprite.scale = Vector2(1, 1)
	orb.add_child(sprite)
	
	get_tree().current_scene.get_parent().add_child(orb)
	orb.global_position = start_pos
	orb.collision_layer = 2
	orb.collision_mask = 1  # 这样即可
	
	# 飞行到目标位置
	var distance = start_pos.distance_to(target_pos)
	var speed = 500.0
	var travel_time = distance / speed
	
	var tween = orb.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(orb, "global_position", target_pos, travel_time)
	tween.tween_callback(func(): _on_guide_orb_arrive(target_pos, scale))
	tween.tween_callback(orb.queue_free)
	
	return orb

func _on_guide_orb_arrive(target_position: Vector2, scale_multiplier: float = 1.0):
	# 阶段2：指引光球到达，创建范围指示器
	print("指引光球到达位置: ", target_position, " 放大倍数: ", scale_multiplier)
	create_range_indicator(target_position, scale_multiplier)
	
	# 阶段3：延迟后发射真正的冰球，传递放大倍数
	await get_tree().create_timer(0).timeout  # 立即发射
	fire_ice_blast(target_position, scale_multiplier)

func create_range_indicator(position: Vector2, scale_multiplier: float = 1.0):
	# 创建范围指示器
	if indicator_scene:
		var indicator = indicator_scene.instantiate()
		get_tree().current_scene.get_parent().add_child(indicator)
		indicator.global_position = position
		# 传递放大倍数给指示器
		if indicator.has("target_scale"):
			indicator.target_scale = scale_multiplier
		if indicator.has_method("start_indicator_animation"):
			indicator.start_indicator_animation()
	else:
		# 代码创建简单的范围指示器
		create_simple_indicator(position, scale_multiplier)

func create_simple_indicator(position: Vector2, scale_multiplier: float = 1.0):
	# 创建一个简单的范围指示器（如果没有场景）
	# 指示器的大小要和第二发真实子弹的 scale 一样
	var indicator = Area2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = load("res://snowball_atlas_texture.tres")
	sprite.modulate = Color(0.3, 0.6, 1.0, 0.5)  # 蓝色，半透明
	
	# 子弹的原始碰撞体半径（从 bullet_snow.tscn 中获取）
	const BULLET_BASE_RADIUS = 12.0
	
	# 直接使用 scale_multiplier，和子弹的 scale 保持一致
	sprite.scale = Vector2(scale_multiplier, scale_multiplier)
	indicator.add_child(sprite)
	indicator.collision_layer = 2
	indicator.collision_mask = 1
	
	# 添加碰撞体（圆形），半径 = 原始半径 * 倍数
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = BULLET_BASE_RADIUS * scale_multiplier
	collision.shape = circle_shape
	
	indicator.add_child(collision)
	
	get_tree().current_scene.get_parent().add_child(indicator)
	indicator.global_position = position
	
	# 动画效果：脉冲 + 淡入淡出
	var tween = indicator.create_tween()
	tween.set_parallel(true)
	
	# 淡入
	tween.tween_property(sprite, "modulate:a", 0.6, 0.3)
	
	# 脉冲效果（循环），基于 scale_multiplier
	var pulse_tween = indicator.create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(sprite, "scale", Vector2(scale_multiplier * 1.1, scale_multiplier * 1.1), 0.5)
	pulse_tween.tween_property(sprite, "scale", Vector2(scale_multiplier, scale_multiplier), 0.5)
	
	# 2秒后淡出并销毁（使用 Timer）
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func():
		var fade_tween = indicator.create_tween()
		fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		fade_tween.tween_callback(indicator.queue_free)
		timer.queue_free()
	)
	indicator.add_child(timer)
	timer.start()

func fire_ice_blast(target_position: Vector2, scale_multiplier: float = 1.0):
	# 阶段3：发射真正的快速冰球（纯Tween实现）
	print("发射真正的冰球到: ", target_position, " 放大倍数: ", scale_multiplier)
	
	var ice_ball = null
	var start_pos = spwan_bullet_mark.global_position
	
	# 创建子弹
	if ice_blast_scene:
		ice_ball = ice_blast_scene.instantiate()
	else:
		# 如果没有场景，使用普通子弹
		if bullet_scene:
			ice_ball = bullet_scene.instantiate()
	
	if not ice_ball:
		print("无法创建冰球：没有可用的场景")
		return
	
	get_tree().current_scene.get_parent().add_child(ice_ball)
	ice_ball.name += "ice_ball"
	# 设置初始位置和状态
	ice_ball.global_position = start_pos
	
	# 如果有setup方法，调用它（但速度设为0，让子弹原地不动）
	var direction = (target_position - start_pos).normalized()
	ice_ball.setup(start_pos, direction, group_name)
	# 设置速度为0，让子弹原地不动（由Tween控制移动）
	ice_ball.bullet_state.bullet_speed = 0.0
	ice_ball.wave_amplitude = 0.0
	
	# 初始缩放（小尺寸）
	var base_scale = Vector2(1.0, 1.0)
	ice_ball.scale = base_scale
	
	# 设置颜色（如果是普通子弹）
	if not ice_blast_scene and bullet_scene:
		ice_ball.modulate = Color(0.5, 0.8, 1.0)  # 蓝色，像冰
	
	# 使用Tween控制移动和缩放
	var main_tween = ice_ball.create_tween()
	
	# 1. 移动：从发射位置到目标位置（0.5秒）
	main_tween.tween_property(ice_ball, "global_position", target_position, 0.5)
	main_tween.tween_callback(func(): _on_ice_ball_arrive(ice_ball, scale_multiplier))

func _on_ice_ball_arrive(ice_ball: Node, scale_multiplier: float):
	# 子弹到达目标位置，立即开始放大动画
	print("冰球到达目标位置，开始放大到倍数: ", scale_multiplier)
	
	# 计算目标缩放（基础大小 * 放大倍数）
	var base_scale = Vector2(1.0, 1.0)
	var target_scale = base_scale * scale_multiplier
	
	# 创建顺序动画：先放大，再淡出
	var main_tween = ice_ball.create_tween()
	
	# 第一阶段：放大动画（0.2秒，弹性效果）
	main_tween.set_trans(Tween.TRANS_ELASTIC)
	main_tween.tween_property(ice_ball, "scale", target_scale, 0.2)
	
	# 第二阶段：放大完成后，逐渐变淡（1秒）
	main_tween.set_trans(Tween.TRANS_LINEAR)  # 淡出用线性过渡
	main_tween.tween_property(ice_ball, "modulate:a", 0.0, 1.0)
	
	# 淡出完成后销毁
	main_tween.tween_callback(ice_ball.queue_free)
