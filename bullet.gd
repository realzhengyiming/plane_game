extends Area2D

var direction: Vector2 = Vector2.ZERO
#var speed: float = 0.0
@export var base_bullet_state: BulletAttribute
var bullet_state: BulletAttribute #: set=bullet_state_set
@onready var label: Label = $Label
@export var is_test_env: bool = UpgradeConfig.IS_TEST_ENV

func _ready() -> void:
	# 离开屏幕销毁
	var notifier = VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	notifier.screen_exited.connect(queue_free)
	bullet_state = base_bullet_state.duplicate()
	bullet_state.bullet_attr_updated.connect(bullet_state_set) # 状态更新吼
	
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

func setup(start_position: Vector2, move_direction: Vector2) -> void:
	position = start_position
	direction = move_direction
	#bullet_state.bullet_speed = move_speed
	label.text = "damage:" + str(bullet_state.bullet_damage)
	label.text += "\n" + "speed:" + str(bullet_state.bullet_speed)
	label.text += "\n" + "cross:" + str(bullet_state.through_times)

func _process(delta: float) -> void:
	position += direction * bullet_state.bullet_speed * delta


func _on_area_entered(area: Area2D) -> void:  # 自己链接自己
	if area.is_in_group("enemy"):
		if bullet_state.through_times <= 0:
			queue_free()  # 子弹就没了
		else:
			bullet_state.through_times -= 1
	pass # Replace with function body.
