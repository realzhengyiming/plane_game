extends Area2D

# 移动和射击参数
@export var move_speed: float = 300.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2
@export var bullet_speed: float = 200.0
@onready var player_sprite: Sprite2D = $Sprite2D

# 生命值相关
@export var max_health: int = 3  # 最大生命值
var current_health: int = max_health  # 当前生命值
signal health_changed(current, max)  # 生命值变化信号（传递当前值和最大值）
signal player_die_signal

var velocity: Vector2 = Vector2.ZERO
var last_fire_time: float = 0.0


func _ready() -> void:
	# 初始化时发射一次信号，让进度条显示初始血量
	emit_signal("health_changed", current_health, max_health)
	# 检测与敌人的碰撞（Area2D之间用area_entered）
	area_entered.connect(_on_enemy_collision)


func _process(delta: float) -> void:
	handle_movement(delta)
	handle_shooting(delta)

func handle_movement(delta: float) -> void:
	# 计算移动向量
	velocity = Input.get_vector("left", "right", "up", "down").normalized() * move_speed
	position += velocity * delta

	# 限制在屏幕范围内
	clamp_to_screen()

func clamp_to_screen() -> void:
	# 获取屏幕（视口）的大小（像素）
	var screen_size = get_viewport_rect().size
	# 获取角色自身的大小（假设是Sprite2D，以中心为锚点）
	var sprite_size = player_sprite.texture.get_size() * scale  # 考虑缩放后的实际大小

	# 计算角色的边界范围（避免角色一半移出屏幕）
	var min_x = sprite_size.x / 2  # 左边界（角色宽度的一半）
	var max_x = screen_size.x - sprite_size.x / 2  # 右边界
	var min_y = sprite_size.y / 2  # 上边界（角色高度的一半）
	var max_y = screen_size.y - sprite_size.y / 2  # 下边界

	# 限制位置在范围内
	position.x = clamp(position.x, min_x, max_x)
	position.y = clamp(position.y, min_y, max_y)

func handle_shooting(delta: float) -> void:
	if Input.is_action_pressed("j"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time > last_fire_time + fire_rate:
			fire_bullet()
			last_fire_time = current_time

func fire_bullet() -> void:
	if not bullet_scene:
		return
		
	var bullet = bullet_scene.instantiate()
	if bullet.has_method("setup"):
		bullet.setup(position, Vector2.UP, bullet_speed)
		get_parent().add_child(bullet)

# 处理与敌人的碰撞
func _on_enemy_collision(area: Area2D) -> void:
	# 假设敌人节点有"is_enemy"方法用于标识（需在敌人脚本中定义）
	if area.has_method("is_enemy"):
		take_damage(1)  # 碰到敌人掉1点血

# 掉血逻辑
func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)  # 确保血量不小于0
	emit_signal("health_changed", current_health, max_health)  # 发射生命值变化信号
	
	if current_health <= 0:
		die()  # 血量为0时死亡

# 玩家死亡处理（可扩展：游戏结束逻辑）
func die() -> void:
	emit_signal("player_die_signal")
	await get_tree().process_frame  # 等待下一帧
	print("玩家死亡！")

	queue_free()  # 暂时简单处理：销毁玩家


# 应用升级（根据类型计算当前等级对应的数值）
func apply_upgrade(upgrade_type: int) -> void:
	# 升级等级+1
	UpgradeConfig.upgrade_levels[upgrade_type] += 1
	var current_level = UpgradeConfig.upgrade_levels[upgrade_type]

	# 从配置表计算本次升级的数值
	var add_value = UpgradeConfig.calculate_upgrade_value(upgrade_type, current_level)

	# 应用到属性
	match upgrade_type:
		UpgradeConfig.UpgradeType.ATTACK_SPEED:
			bullet_speed -= add_value  # 取整
			print("子弹速度 +", add_value, " → 当前子弹速度", bullet_speed)
		UpgradeConfig.UpgradeType.HEALTH_UP:
			max_health += add_value
			current_health = max_health  # 满血
			print("生命值上限 +", add_value, " → 总上限：", current_health)
		UpgradeConfig.UpgradeType.SPEED_UP:
			move_speed *= (1 + add_value)  # 百分比提升
			print("移动速度 +", add_value * 100, "% → 总速度：", move_speed)
