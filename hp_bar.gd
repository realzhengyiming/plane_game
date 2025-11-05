extends ProgressBar

func _ready() -> void:
	pass
	
	
func _process(delta: float) -> void:
	# 计算当前进度比例（0~1）
	var ratio = value / max_value

	# 按比例从高到低判断，用 elif 确保只执行一个条件
	if ratio >= 0.7:
		# 高进度：绿色
		add_theme_color_override("progress", Color(0, 1, 0))  # 绿色
	elif ratio >= 0.4:
		# 中进度：蓝色
		add_theme_color_override("progress", Color(0, 0, 1))  # 蓝色
	else:
		# 低进度：红色
		add_theme_color_override("progress", Color(1, 0, 0))  # 红色
