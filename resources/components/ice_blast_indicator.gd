extends Area2D
class_name IceBlastIndicator

# 范围指示器：显示冰魂大招的预警范围

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var target_scale: float = 1.0
var lifetime: float = 2.0  # 显示时长
var elapsed_time: float = 0.0

func _ready():
	# 初始状态：完全透明，小尺寸
	modulate.a = 0.0
	scale = Vector2(0.1, 0.1)
	
	# 开始动画：淡入 + 放大
	start_indicator_animation()

func start_indicator_animation():
	var tween = create_tween()
	tween.set_parallel(true)  # 并行执行多个动画
	
	# 淡入效果
	tween.tween_property(self, "modulate:a", 0.6, 0.3)  # 半透明
	
	# 放大效果（脉冲）
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.3)
	
	# 持续脉冲效果
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(self, "scale", Vector2(target_scale * 1.1, target_scale * 1.1), 0.5)
	pulse_tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.5)

func _process(delta):
	elapsed_time += delta
	if elapsed_time >= lifetime:
		# 淡出并销毁
		var fade_tween = create_tween()
		fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
		fade_tween.tween_callback(queue_free)

