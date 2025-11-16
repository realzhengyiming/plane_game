extends Area2D

# 已有的属性...
@export var fall_speed: float = 150.0
@export var health: int = 2
@export var spawn_range: Vector2 = Vector2(200, 800)
signal enemy_destroyed()
@onready var exploed_node: CPUParticles2D = $"爆炸粒子"

# 新增：标识自身为敌人（供玩家碰撞检测）
func is_enemy() -> bool:
	return true

# 其余代码保持不变...
func _ready() -> void:
	position.x = randf_range(spawn_range.x, spawn_range.y)
	area_entered.connect(_on_area_entered)
	exploed_node.finished.connect(die)

func _process(delta: float) -> void:
	position += Vector2.DOWN * fall_speed * delta
	if position.y > get_viewport_rect().size.y + 50:  # 还真是随机
		queue_free()

	#if Input.is_action_pressed("j"):
		#exploed_node.emitting()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_bullet"):
		health -= area.bullet_state.bullet_damage
		if health <= 0:
			exploed_node.start_explode()


func _after_die() -> void:
	emit_signal("enemy_destroyed")
	# 生成 掉落物

func die():
	queue_free()
