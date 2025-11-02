extends CanvasLayer

@onready var start_button = $Button  # “开始游戏”按钮

func _ready():
	start_button.pressed.connect(_on_button_pressed)
	print("游戏结束UI界面打开了!")

func _on_button_pressed() -> void:
	pass # Replace with function body.
	# 销毁可能存在的旧游戏场景（避免多场景叠加）
	var old_game_scene = get_tree().root.get_node_or_null("GameScence")  # todo gameover应该回到 game start 才对
	if old_game_scene:
		old_game_scene.queue_free()
		
	# 实例化全新的游戏场景（初始状态）
	var game_start = preload("res://ui/game_start_ui.tscn").instantiate()
	#new_game_scene.name = "GameScene"  # 给场景命名，方便后续查找
	get_tree().root.add_child(game_start)
	
	# 销毁当前开始界面
	queue_free()
