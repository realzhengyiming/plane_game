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

@export var max_health:float = 4
@export var hp: float = 1000: set = set_hp

var first_state_timer = Timer.new()  # 先创建，但是不启动

func set_hp(value):
	hp = value
	progress_bar.value = value
	if hp <= max_health / 2:
		state_chart.send_event("to_无敌状态")
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
	pass # Replace with function body.
	# todo 配置几秒的无敌
	collision_polygon_2d.disabled = true
	# 增加shadow 闪烁抖动啥的
	print("正在无敌状态")
	var timer = Timer.new()
	timer.wait_time = 2
	timer.autostart = true
	timer.timeout.connect(invincible_timeout)
	add_child(timer)

	
func invincible_timeout():
	collision_polygon_2d.disabled = false
	print("无敌状态解除")	


func _on_hp_half_state_entered() -> void:
	pass # Replace with function body.
	shoot_timer.autostart = true
	rotation_timer.autostart = true
	
	shoot_timer.timeout.connect(fire_bullet_heavn)
	rotation_timer.timeout.connect(rota_direction)
