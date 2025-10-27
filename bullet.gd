extends Area2D  # 必须与根节点类型一致

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0

# 这个setup方法必须存在，玩家会调用它
func setup(start_position: Vector2, move_direction: Vector2, move_speed: float) -> void:
	position = start_position  # 设置初始位置
	direction = move_direction  # 接收向上的方向
	speed = move_speed  # 接收速度

# 每帧移动（确保此函数存在）
func _process(delta: float) -> void:
	position += direction * speed * delta  # 向上移动的核心逻辑

# 自动添加屏幕离开检测（无需手动添加节点）
func _ready() -> void:
	var notifier = VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	notifier.screen_exited.connect(queue_free)  # 离开屏幕就销毁
