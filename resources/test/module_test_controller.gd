extends Node2D
# 模块组合方块升级系统的测试控制器

@export var root_module_scene: PackedScene
var root_module: BaseBoxModule = null

func _ready() -> void:
	print("=== 模块组合方块升级系统测试 ===")
	
	# 创建根模块
	if root_module_scene:
		root_module = root_module_scene.instantiate() as BaseBoxModule
		if root_module:
			add_child(root_module)
			root_module.position = Vector2(400, 300)
			
			# 测试：添加一些模块
			test_add_modules()
			
			# 测试：遍历所有模块
			test_traverse_modules()
			
			# 测试：保存和加载
			test_save_and_load()
	else:
		print("错误：请设置 root_module_scene")

# 测试添加模块
func test_add_modules():
	print("\n--- 测试添加模块 ---")
	if not root_module:
		return
	
	# 创建测试模块
	var test_module1 = root_module_scene.instantiate() as BaseBoxModule
	var test_module2 = root_module_scene.instantiate() as BaseBoxModule
	var test_module3 = root_module_scene.instantiate() as BaseBoxModule
	
	if test_module1 and test_module2 and test_module3:
		# 在右侧添加模块1
		root_module.append_module_to_direction(test_module1, BaseBoxModule.Direction.RIGHT)
		print("在右侧添加了模块1")
		
		# 在模块1的上方添加模块2
		test_module1.append_module_to_direction(test_module2, BaseBoxModule.Direction.UP)
		print("在模块1的上方添加了模块2")
		
		# 在模块1的下方添加模块3
		test_module1.append_module_to_direction(test_module3, BaseBoxModule.Direction.DOWN)
		print("在模块1的下方添加了模块3")
		
		print("模块添加完成！")

# 测试遍历所有模块
func test_traverse_modules():
	print("\n--- 测试遍历所有模块 ---")
	if not root_module:
		return
	
	var all_modules = root_module.get_all_connected_modules()
	print("找到 ", all_modules.size(), " 个连接的模块（不包括根模块）")
	
	# 使用回调遍历
	var module_count = 0
	root_module.traverse_all_modules({}, func(module: BaseBoxModule):
		module_count += 1
		print("遍历到模块 ", module_count, " 位置: ", module.position)
	)
	print("总共遍历了 ", module_count, " 个模块（包括根模块）")

# 测试保存和加载
func test_save_and_load():
	print("\n--- 测试保存和加载 ---")
	if not root_module:
		return
	
	# 打印当前模块数据
	print("当前根模块的 module_data:")
	for direction in root_module.module_data:
		print("  方向 ", direction, ": ", root_module.module_data[direction])
	
	# 注意：实际保存到文件需要额外的序列化逻辑
	# 这里只是演示数据结构
