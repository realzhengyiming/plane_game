extends Node2D
class_name BaseBoxModule
# 它有四个模块, 可以通过拖拽, 增加或者删除模块组合
@onready var sub_modules: Node2D = $sub_modules
@onready var sprite: Sprite2D = $Sprite2D
@onready var up_marker: Marker2D = $up_marker
@onready var down_marker: Marker2D = $down_marker
@onready var left_marker: Marker2D = $left_marker
@onready var right_marker: Marker2D = $right_marker

# 存储四个方向的连接模块（使用字典存储，key为方向，value为模块实例）
var connected_modules: Dictionary = {}

# 存储模块数据的结构（用于序列化和初始化）
# 格式：{direction: {module_scene: PackedScene, module_data: Dictionary}}
@export var module_data: Dictionary = {}

# 模块场景引用（用于创建新模块）
@export var module_scene: PackedScene

# 根节点颜色和子节点颜色
@export var root_color: Color = Color(1.0, 0.5, 0.5, 1.0)  # 红色（根节点）
@export var child_color: Color = Color(0.5, 0.5, 1.0, 1.0)  # 蓝色（子节点）

enum Direction { UP, DOWN, LEFT, RIGHT }

# 获取方向对应的Marker2D
func get_marker_by_direction(direction: Direction) -> Marker2D:
	match direction:
		Direction.UP:
			return up_marker
		Direction.DOWN:
			return down_marker
		Direction.LEFT:
			return left_marker
		Direction.RIGHT:
			return right_marker
	return null

# 获取相反方向
func get_opposite_direction(direction: Direction) -> Direction:
	match direction:
		Direction.UP:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.UP
		Direction.LEFT:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.LEFT
	return Direction.UP

# 判断是否是根节点（没有父模块连接）
func is_root_node() -> bool:
	var parent = get_parent()
	# 如果父节点是sub_modules，说明是子模块（sub_modules的父节点是BaseBoxModule）
	if parent and parent.name == "sub_modules":
		return false
	# 如果父节点直接是BaseBoxModule，也是子模块
	if parent is BaseBoxModule:
		return false
	# 其他情况是根节点
	return true

# 获取sprite的尺寸（考虑scale）
func get_sprite_size() -> Vector2:
	if sprite and sprite.texture:
		var tex_size = sprite.texture.get_size()
		return tex_size * sprite.scale
	return Vector2(64, 64)  # 默认尺寸

# 在指定方向添加模块
func append_module_to_direction(module: BaseBoxModule, direction: Direction):
	if connected_modules.has(direction):
		print("警告：方向 ", direction, " 已经有模块了，将被替换")
	
	# 确保新模块有module_scene设置（如果没有，尝试从场景文件路径加载）
	if not module.module_scene:
		var scene_path = module.scene_file_path
		if scene_path and scene_path != "":
			module.module_scene = load(scene_path) as PackedScene
	
	connected_modules[direction] = module
	sub_modules.add_child(module)
	
	# 计算边缘对齐的位置（而不是中心对齐）
	# 获取当前模块和新模块的sprite尺寸
	var current_size = get_sprite_size()
	var new_module_size = module.get_sprite_size()
	
	# 计算padding（每个模块尺寸的一半）
	var current_padding = current_size / 2.0
	var new_module_padding = new_module_size / 2.0
	
	# 计算总偏移量：当前模块边缘 + 新模块边缘 = 当前padding + 新模块padding
	var total_offset = current_padding + new_module_padding
	
	# 根据方向计算位置
	var offset = Vector2.ZERO
	match direction:
		Direction.UP:
			offset = Vector2(0, -total_offset.y)
		Direction.DOWN:
			offset = Vector2(0, total_offset.y)
		Direction.LEFT:
			offset = Vector2(-total_offset.x, 0)
		Direction.RIGHT:
			offset = Vector2(total_offset.x, 0)
	
	# 设置模块位置（相对于当前模块中心）
	module.position = offset
	
	# 双向连接：在连接的模块的反方向也记录当前模块
	var opposite_dir = get_opposite_direction(direction)
	module.connected_modules[opposite_dir] = self
	
	# 更新新模块的颜色（因为它是子模块，不是根节点）
	module.update_color()
	
	# 保存数据到module_data（用于序列化）
	if not module_data.has(direction):
		module_data[direction] = {}
	# 保存模块场景的路径（优先使用module_scene的resource_path，否则使用scene_file_path）
	var scene_path = ""
	if module.module_scene:
		scene_path = module.module_scene.resource_path
	elif module.scene_file_path:
		scene_path = module.scene_file_path
	module_data[direction]["module_scene"] = scene_path
	module_data[direction]["module_data"] = module.module_data

# 移除指定方向的模块
func remove_module_from_direction(direction: Direction):
	if connected_modules.has(direction):
		var module = connected_modules[direction]
		var opposite_dir = get_opposite_direction(direction)
		
		# 断开双向连接
		if module.connected_modules.has(opposite_dir):
			module.connected_modules.erase(opposite_dir)
		
		connected_modules.erase(direction)
		module_data.erase(direction)
		
		if is_instance_valid(module):
			module.queue_free()

# 遍历所有连接的模块（深度优先遍历）
func traverse_all_modules(visited: Dictionary = {}, callback: Callable = Callable()) -> Dictionary:
	if visited.has(self):
		return visited
	
	visited[self] = true
	
	# 执行回调函数（如果提供）
	if callback.is_valid():
		callback.call(self)
	
	# 遍历所有方向的连接模块
	for direction in connected_modules:
		var connected_module = connected_modules[direction]
		if connected_module and is_instance_valid(connected_module):
			connected_module.traverse_all_modules(visited, callback)
	
	return visited

# 获取所有连接的模块（返回数组）
func get_all_connected_modules() -> Array[BaseBoxModule]:
	var visited: Dictionary = {}
	var result: Array[BaseBoxModule] = []
	
	traverse_all_modules(visited, func(module: BaseBoxModule):
		result.append(module)
	)
	
	return result

# 从存储的数据初始化子模块（递归生成）
func initialize_from_data():
	# 清除现有的连接模块
	for direction in connected_modules.keys():
		var module = connected_modules[direction]
		if is_instance_valid(module):
			module.queue_free()
	connected_modules.clear()
	
	# 如果没有模块场景引用，尝试从当前场景获取
	if not module_scene and scene_file_path:
		module_scene = load(scene_file_path) as PackedScene
	
	# 如果没有模块场景，无法创建子模块
	if not module_scene:
		print("警告：没有设置 module_scene，无法创建子模块")
		return
	
	# 遍历module_data，创建所有子模块
	for direction_key in module_data:
		var direction = direction_key as Direction
		var data = module_data[direction_key]
		
		if data.has("module_scene") and data.has("module_data"):
			var scene_path = data["module_scene"]
			if scene_path and scene_path != "":
				var scene = load(scene_path) as PackedScene
				if scene:
					var new_module = scene.instantiate() as BaseBoxModule
					if new_module:
						# 设置子模块的数据
						new_module.module_scene = scene
						new_module.module_data = data["module_data"]
						
						# 添加到当前模块
						append_module_to_direction(new_module, direction)
						
						# 递归初始化子模块
						new_module.initialize_from_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 如果没有设置module_scene，尝试从场景文件路径加载
	if not module_scene:
		var scene_path = scene_file_path
		if scene_path and scene_path != "":
			module_scene = load(scene_path) as PackedScene
	
	# 设置颜色：根节点和子节点不同颜色
	update_color()
	
	# 如果是根节点，从数据初始化
	if module_data.size() > 0:
		initialize_from_data()

# 更新模块颜色
func update_color():
	if sprite:
		if is_root_node():
			sprite.modulate = root_color
		else:
			sprite.modulate = child_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
