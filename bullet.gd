extends Area2D

var direction: Vector2 = Vector2.ZERO
#var speed: float = 0.0
@export var base_bullet_state: BulletAttribute
var bullet_state: BulletAttribute #: set=bullet_state_set
@onready var label: Label = $Label
@export var is_test_env: bool = UpgradeConfig.IS_TEST_ENV

# -------------------------- 新增波浪轨迹参数 --------------------------
@export var wave_amplitude: float = 40.0  # 波浪幅度（偏移最大距离）
@export var wave_frequency: float = 5.0   # 波浪频率（每秒摆动次数）
@export var random_wave_phase: bool = true # 是否随机初始相位（避免弹幕同步）
var time_alive: float = 0.0                # 子弹存活时间（计算波浪用）
#var wave_phase_offset: float = 0.0         # 波浪初始相位偏移
@export var group_name:String = UpgradeConfig.IS_ENEMY

func _ready() -> void:
	# 离开屏幕销毁
	var notifier = VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	notifier.screen_exited.connect(queue_free)
	bullet_state = base_bullet_state.duplicate()
	bullet_state.bullet_attr_updated.connect(bullet_state_set) # 状态更新吼
	
	# -------------------------- 新增：初始化波浪相位 --------------------------
	#if random_wave_phase:
		#wave_phase_offset = rand_range(0, 2 * PI) # 随机初始相位，避免弹幕同步
	
	if is_test_env == true:
		label.visible = true
	else:
		label.visible = false
	
func bullet_state_set(input_bullet_state):
	label.text = "damage:" + str(input_bullet_state.bullet_damage)
	label.text += "\n" + "speed:" + str(input_bullet_state.bullet_speed)
	label.text += "\n" + "cross:" + str(input_bullet_state.through_times)
	
	
# 标记为子弹（供敌人识别）
func is_bullet() -> bool:
	return true

func setup(start_position: Vector2, move_direction: Vector2, add2group_name:String) -> void:
	global_position = start_position
	direction = move_direction.normalized() # 确保方向是单位向量（关键！）
	#bullet_state.bullet_speed = move_speed
	label.text = "damage:" + str(bullet_state.bullet_damage)
	label.text += "\n" + "speed:" + str(bullet_state.bullet_speed)
	label.text += "\n" + "cross:" + str(bullet_state.through_times)
	add_to_group(add2group_name)  # 添加到分组

#func setup_by_target_position(start_position:Vector2, )

func _process(delta: float) -> void:
	# -------------------------- 修改：波浪轨迹计算 --------------------------
	time_alive += delta # 累计存活时间
	
	# 1. 计算发射方向的垂直法向量（决定偏移方向：上下/左右）
	var normal_dir: Vector2 = Vector2(-direction.y, direction.x) # 左侧法向量
	# 若要反向偏移，改用：Vector2(direction.y, -direction.x)（右侧法向量）
	
	# 2. 计算正弦偏移量（加入初始相位避免同步）
	var wave_offset_value: float = wave_amplitude * sin(2 * PI * wave_frequency * time_alive)
	
	# 3. 组合基础移动和波浪偏移
	var base_movement: Vector2 = direction * bullet_state.bullet_speed * delta # 原直线移动
	var wave_movement: Vector2 = normal_dir * wave_offset_value * delta        # 波浪偏移（乘delta保证帧率无关）
	
	# 4. 最终位置更新
	global_position += base_movement + wave_movement


func _on_area_entered(area: Area2D) -> void:  # 自己链接自己
	if not area.has_meta("group_name"):
		print("没有group_name这个属性")
		return  #  没有就跳过
	print("area_name", area.group_name)
	if area.group_name not in get_groups():  # 不同分组的就可以造成伤害
		
		if bullet_state.through_times <= 0:
			queue_free()  # 子弹就没了
		else:
			bullet_state.through_times -= 1
	pass # Replace with function body.
