extends Control
class_name ModuleEditorUI

# 左侧预览区域（2/3屏幕）
@onready var preview_area: Control = $HSplitContainer/PreviewArea
@onready var preview_viewport: SubViewportContainer = $HSplitContainer/PreviewArea/SubViewportContainer
@onready var preview_subviewport: SubViewport = $HSplitContainer/PreviewArea/SubViewportContainer/SubViewport
@onready var preview_scene: Node2D = $HSplitContainer/PreviewArea/SubViewportContainer/SubViewport/PreviewScene

# 右侧模块列表（1/3屏幕）
@onready var module_list_container: ScrollContainer = $HSplitContainer/ModuleListContainer
@onready var module_list: VBoxContainer = $HSplitContainer/ModuleListContainer/ModuleList

# 根模块场景
@export var root_module_scene: PackedScene

# 当前编辑的根模块
var root_module: BaseBoxModule = null

# 用户拥有的模块列表（格式：{module_scene: PackedScene, count: int}）
@export var available_modules: Array[Dictionary] = []

# 拖拽相关
var is_dragging: bool = false
var dragged_module_item: Control = null
var dragged_module_scene: PackedScene = null
var drag_preview: BaseBoxModule = null

# 当前悬停的模块和方向
var hovered_module: BaseBoxModule = null
var hovered_direction: BaseBoxModule.Direction = BaseBoxModule.Direction.UP

func _ready() -> void:
	# 等待一帧确保SubViewport已初始化
	await get_tree().process_frame
	
	print("=== 模块编辑器初始化 ===")
	print("root_module_scene: ", root_module_scene)
	print("available_modules 初始大小: ", available_modules.size())
	
	# 如果available_modules为空，初始化默认的10个base_module
	if root_module_scene:
		if available_modules.size() == 0:
			print("available_modules为空，初始化默认模块...")
			available_modules.clear()
			# 合并为单个条目，数量为10（更合理）
			available_modules.append({
				"module_scene": root_module_scene,
				"count": 10
			})
			print("已初始化 ", available_modules.size(), " 个模块类型，总数量: ", available_modules[0]["count"])
		else:
			print("使用已有的available_modules，大小: ", available_modules.size())
		
		# 初始化根模块
		root_module = root_module_scene.instantiate() as BaseBoxModule
		if root_module:
			preview_scene.add_child(root_module)
			# 将根模块放在SubViewport中心
			var viewport_size = preview_subviewport.size
			root_module.position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)
			print("根模块已创建并放置在中心")
		else:
			print("错误：无法实例化根模块")
	else:
		print("警告：root_module_scene未设置！请在编辑器中设置root_module_scene")
	
	# 初始化模块列表
	update_module_list()

# 更新右侧模块列表
func update_module_list():
	print("=== 更新模块列表 ===")
	print("available_modules 大小: ", available_modules.size())
	
	# 清除现有列表
	for child in module_list.get_children():
		child.queue_free()
	
	# 等待一帧确保清理完成
	await get_tree().process_frame
	
	# 创建模块项（只显示数量大于0的模块）
	var item_count = 0
	for module_data in available_modules:
		if module_data.has("module_scene") and module_data.has("count"):
			if module_data["count"] > 0:
				print("创建模块项: count=", module_data["count"])
				await create_module_list_item(module_data["module_scene"], module_data["count"])
				item_count += 1
			else:
				print("跳过模块项: count=0")
		else:
			print("警告：模块数据格式不正确: ", module_data)
	
	print("共创建了 ", item_count, " 个模块列表项")

# 创建模块列表项
func create_module_list_item(module_scene: PackedScene, count: int):
	var item_scene = load("res://resources/test/module_list_item.tscn") as PackedScene
	if not item_scene:
		print("错误：无法加载 module_list_item.tscn")
		return
	
	var item = item_scene.instantiate()
	module_list.add_child(item)
	
	# 等待一帧确保节点树已准备好，@onready变量已初始化
	await get_tree().process_frame
	
	# 设置模块项数据
	if item.has_method("setup"):
		item.setup(module_scene, count, self)
		# 再等待一帧确保预览已更新
		await get_tree().process_frame

# 开始拖拽模块
func start_drag_module(module_scene: PackedScene, item: Control):
	is_dragging = true
	dragged_module_item = item
	dragged_module_scene = module_scene
	
	# 创建拖拽预览
	if module_scene:
		drag_preview = module_scene.instantiate() as BaseBoxModule
		if drag_preview:
			preview_scene.add_child(drag_preview)
			drag_preview.modulate = Color(1, 1, 1, 0.7)  # 半透明
			drag_preview.z_index = 100

# 结束拖拽
func end_drag_module():
	if drag_preview:
		drag_preview.queue_free()
		drag_preview = null
	
	is_dragging = false
	dragged_module_item = null
	dragged_module_scene = null
	hovered_module = null

# 处理鼠标移动（在预览区域）
func _input(event: InputEvent) -> void:
	if not is_dragging or not drag_preview:
		return
	
	if event is InputEventMouseMotion:
		# 获取鼠标在SubViewport中的位置
		var mouse_global = get_global_mouse_position()
		var viewport_global = preview_viewport.get_global_rect()
		
		# 检查鼠标是否在预览区域内
		if viewport_global.has_point(mouse_global):
			# 计算相对于SubViewport的本地坐标
			var local_pos = mouse_global - viewport_global.position
			# 考虑SubViewport的缩放
			var viewport_size = preview_subviewport.size
			var container_size = preview_viewport.size
			var scale_factor = Vector2(viewport_size.x / container_size.x, viewport_size.y / container_size.y)
			var scene_pos = local_pos * scale_factor
			
			drag_preview.position = scene_pos
			
			# 检测是否可以吸附
			check_module_attachment(scene_pos)
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# 检查鼠标是否在预览区域内
			var viewport_rect = preview_viewport.get_global_rect()
			var mouse_global = get_global_mouse_position()
			
			if viewport_rect.has_point(mouse_global):
				# 鼠标释放，尝试放置模块
				if hovered_module and dragged_module_scene:
					attach_module_to_direction(hovered_module, hovered_direction, dragged_module_scene)
					# 减少模块数量
					decrease_module_count(dragged_module_scene)
			end_drag_module()

# 检测模块吸附位置
func check_module_attachment(mouse_pos: Vector2):
	hovered_module = null
	
	# 遍历所有模块，找到最近的模块和方向
	var min_distance = INF
	var closest_module: BaseBoxModule = null
	var closest_direction: BaseBoxModule.Direction = BaseBoxModule.Direction.UP
	
	# 遍历所有模块（包括根模块）
	var all_modules: Array[BaseBoxModule] = []
	if root_module:
		all_modules = root_module.get_all_connected_modules()
		all_modules.append(root_module)
	
	for module in all_modules:
		var module_pos = module.position
		var module_size = module.get_sprite_size()
		var padding = module_size / 2.0
		
		# 检查四个方向
		var directions = [
			BaseBoxModule.Direction.UP,
			BaseBoxModule.Direction.DOWN,
			BaseBoxModule.Direction.LEFT,
			BaseBoxModule.Direction.RIGHT
		]
		
		for direction in directions:
			# 检查这个方向是否已经有模块
			if module.connected_modules.has(direction):
				continue
			
			# 计算这个方向的吸附位置
			var attach_pos = calculate_attach_position(module, direction)
			var distance = mouse_pos.distance_to(attach_pos)
			
			# 检查是否在吸附范围内（模块尺寸的一半）
			var attach_range = module_size.length() * 0.3
			if distance < attach_range and distance < min_distance:
				min_distance = distance
				closest_module = module
				closest_direction = direction
	
	hovered_module = closest_module
	hovered_direction = closest_direction
	
	# 更新拖拽预览位置
	if hovered_module:
		var attach_pos = calculate_attach_position(hovered_module, hovered_direction)
		drag_preview.position = attach_pos
		drag_preview.modulate = Color(0.5, 1.0, 0.5, 0.7)  # 绿色表示可以放置
	else:
		drag_preview.modulate = Color(1, 1, 1, 0.7)  # 白色表示不能放置

# 计算吸附位置
func calculate_attach_position(module: BaseBoxModule, direction: BaseBoxModule.Direction) -> Vector2:
	var module_pos = module.position
	var module_size = module.get_sprite_size()
	var current_padding = module_size / 2.0
	
	# 假设新模块尺寸相同（实际应该从dragged_module_scene获取）
	var new_module_size = module_size
	var new_module_padding = new_module_size / 2.0
	var total_offset = current_padding + new_module_padding
	
	var offset = Vector2.ZERO
	match direction:
		BaseBoxModule.Direction.UP:
			offset = Vector2(0, -total_offset.y)
		BaseBoxModule.Direction.DOWN:
			offset = Vector2(0, total_offset.y)
		BaseBoxModule.Direction.LEFT:
			offset = Vector2(-total_offset.x, 0)
		BaseBoxModule.Direction.RIGHT:
			offset = Vector2(total_offset.x, 0)
	
	return module_pos + offset

# 将模块吸附到指定方向
func attach_module_to_direction(target_module: BaseBoxModule, direction: BaseBoxModule.Direction, module_scene: PackedScene):
	if not module_scene:
		return
	
	var new_module = module_scene.instantiate() as BaseBoxModule
	if new_module:
		target_module.append_module_to_direction(new_module, direction)
		print("模块已添加到方向: ", direction)

# 减少模块数量
func decrease_module_count(module_scene: PackedScene):
	for module_data in available_modules:
		if module_data.has("module_scene") and module_data["module_scene"] == module_scene:
			if module_data.has("count") and module_data["count"] > 0:
				module_data["count"] -= 1
				update_module_list()
				break

# 获取当前编辑的模块数据结构
func get_module_data() -> Dictionary:
	if root_module:
		return root_module.module_data
	return {}

# 保存模块数据
func save_module_data() -> Dictionary:
	if root_module:
		# 返回根模块的完整数据结构
		return {
			"module_data": root_module.module_data,
			"module_scene": root_module.scene_file_path if root_module.scene_file_path else ""
		}
	return {}

# 加载模块数据
func load_module_data(data: Dictionary):
	if not root_module:
		return
	
	if data.has("module_data"):
		root_module.module_data = data["module_data"]
		root_module.initialize_from_data()
