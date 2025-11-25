extends Node

enum ModuleConnDirection { UNKNOW, UP, DOWN, LEFT, RIGHT }

# 新增：方向对应的位置偏移（关键！控制子模块相对于父模块的位置）
static func get_direction_offset(direction: ModuleConnDirection) -> Vector2:
	var module_size = Vector2(64, 64)  # 假设每个模块的尺寸是 64x64（根据你的模块大小修改）
	var gap = 0  # 模块间间距（无缝连接设为0，需要间隙可调整）
	match direction:
		ModuleConnDirection.UP:
			return Vector2(0, -module_size.y - gap)  # 父模块上方（y轴负方向）
		ModuleConnDirection.DOWN:
			return Vector2(0, module_size.y + gap)   # 父模块下方（y轴正方向）
		ModuleConnDirection.LEFT:
			return Vector2(-module_size.x - gap, 0)  # 父模块左侧（x轴负方向）
		ModuleConnDirection.RIGHT:
			return Vector2(module_size.x + gap, 0)   # 父模块右侧（x轴正方向）
		_:
			return Vector2.ZERO  # 未知方向默认不偏移
