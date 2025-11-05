extends CanvasLayer

@onready var start_button = $Button  # “开始游戏”按钮

func _ready():
	start_button.pressed.connect(_on_button_pressed)
	print("游戏结束UI界面打开了!")

func _on_button_pressed() -> void:
	# 获取根节点（Viewport）
	#var root = get_tree().root
#
	## 1. 先删除根节点下除了 "start_game_ui" 之外的所有子节点
	## （注意：遍历前先把节点存到临时数组，避免遍历中修改节点树导致错误）
	#var children_to_remove = []
	#for child in root.get_children():
		## 只保留名为 "start_game_ui" 的节点（如果存在）
		#if child.name != "start_game_ui":
			#children_to_remove.append(child)
#
	## 执行删除
	#for child in children_to_remove:
		#child.queue_free()
#
	## 2. 实例化新的开始界面（如果根节点中没有 "start_game_ui"，则添加）
	## 防止重复添加：先检查是否已存在
	#var existing_start_ui = root.get_node_or_null("start_game_ui")
	#if not existing_start_ui:
		#var game_start = preload("res://ui/game_start_ui.tscn").instantiate()
		#game_start.name = "start_game_ui"  # 强制命名，确保后续能识别
		#root.add_child(game_start)
	#else:
		#print("开始界面已存在，无需重复添加")
#
	## 3. 销毁当前的 Game Over 界面（当前节点）
	#queue_free()
	get_tree().change_scene_to_file("res://ui/game_start_ui.tscn")
