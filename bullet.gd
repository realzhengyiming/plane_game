extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0


# 标记为子弹（供敌人识别）
func is_bullet() -> bool:
	return true

func setup(start_position: Vector2, move_direction: Vector2, move_speed: float) -> void:
	position = start_position
	direction = move_direction
	speed = move_speed

func _process(delta: float) -> void:
	position += direction * speed * delta

func _ready() -> void:
	# 离开屏幕销毁
	var notifier = VisibleOnScreenNotifier2D.new()
	add_child(notifier)
	notifier.screen_exited.connect(queue_free)
