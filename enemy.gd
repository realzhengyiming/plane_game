extends Area2D

# 已有的属性...
@export var fall_speed: float = 150.0
@export var health: float = 2
#@export var spawn_range: Vector2
signal enemy_destroyed()
@onready var exploed_node: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var spawn_x_offset: float = 50.0  # 左右边距（防止敌机一半在屏幕外）
@export var group_name:String = UpgradeConfig.IS_ENEMY

# 新增：标识自身为敌人（供玩家碰撞检测）
func is_enemy() -> bool:
	return true

# 其余代码保持不变...
func _ready() -> void:
	var screen_width = get_viewport_rect().size.x
	var spawn_min_x = spawn_x_offset
	var spawn_max_x = screen_width - spawn_x_offset
	position.x = randf_range(spawn_min_x, spawn_max_x)
	area_entered.connect(_on_area_entered)
	exploed_node.finished.connect(die)
	exploed_node.texture = sprite_2d.texture

func _process(delta: float) -> void:
	position += Vector2.DOWN * fall_speed * delta
	if position.y > get_viewport_rect().size.y + 50:  # 还真是随机
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("is_bullet"):
		health -= area.bullet_state.bullet_damage
		if health <= 0:
			collision_layer = 2
			collision_mask = 2
			sprite_2d.visible = false
			exploed_node.start_explode()

func die():
	queue_free()
	emit_signal("enemy_destroyed")
