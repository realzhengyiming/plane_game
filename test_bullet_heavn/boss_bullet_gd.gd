extends Area2D
@onready var spwan_bullet_mark: Marker2D = $Marker2D
@export var bullet_scene: PackedScene
@onready var shoot_timer: Timer = $shoot_timer
@onready var rotation_timer: Timer = $rotation_timer
var direction: Vector2 = Vector2.DOWN
@export var group_name:String = UpgradeConfig.IS_ENEMY
var hp: float = 1000: set = set_hp
@onready var progress_bar: ProgressBar = $ProgressBar


func set_hp(value):
	hp = value
	progress_bar.value = value

func _ready() -> void:
	shoot_timer.autostart = true
	rotation_timer.autostart = true
	
	shoot_timer.timeout.connect(fire_bullet)
	rotation_timer.timeout.connect(rota_direction)
	progress_bar.max_value = 1000
	hp = 1000


func rota_direction():
	# 按照每0.5s旋转多少弧
	print("宣传了角度")
	direction = direction.rotated(deg_to_rad(10))  # 还是说直接自己转了，


func fire_bullet() -> void:
	print("进来发射了")

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
		bullet.bullet_state.bullet_speed = 100
		bullet.wave_amplitude = 50
		
		bullet.wave_frequency = 0.5


func _on_area_entered(area: Area2D) -> void:
	# 被子弹打了，就扣血
	pass # Replace with function body.
	if area.is_in_group("player"):
		print("玩家的子弹进来了")
		hp -= area.bullet_state.bullet_damage
