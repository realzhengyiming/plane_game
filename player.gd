extends Area2D

@export var move_speed: float = 300.0
@export var bullet_scene: PackedScene  # 必须关联子弹场景
@export var fire_rate: float = 0.2
@export var bullet_speed: float = 500.0  # 子弹速度（确保为正数）

var velocity: Vector2 = Vector2.ZERO
var last_fire_time: float = 0.0

func _process(delta: float) -> void:
	handle_movement(delta)
	handle_shooting(delta)

func handle_movement(delta: float) -> void:
	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized() * move_speed
	position += velocity * delta

func handle_shooting(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time > last_fire_time + fire_rate:
			fire_bullet()
			last_fire_time = current_time

func fire_bullet() -> void:
	if not bullet_scene:
		print("错误：未设置子弹场景！")
		return
		
	# 实例化子弹并强制转换类型（关键修复）
	var bullet = bullet_scene.instantiate()
	if not bullet.has_method("setup"):
		print("错误：子弹场景缺少setup方法！")
		return
		
	# 调用子弹的setup方法传递参数（替代元数据，更可靠）
	bullet.setup(position, Vector2.UP, bullet_speed)
	get_parent().add_child(bullet)
