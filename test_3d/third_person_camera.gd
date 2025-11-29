extends Node3D
class_name ThirdPersonCamera

# 相机控制器：生化危机5风格控制方式
# 鼠标旋转控制角色朝向，相机固定在玩家正面（越肩视角）
# WASD相对于角色朝向移动

@export var camera: Camera3D = null
@export var target: Node3D = null  # 跟随的目标（玩家）

# 鼠标灵敏度
@export var mouse_sensitivity: float = 0.003

# 相机距离和高度（相对于目标）- 越肩视角通常距离较近
@export var camera_distance: float = 2.0
@export var camera_height: float = 1.5

# 俯仰角限制（可选，生化危机5通常只有水平旋转）
@export var enable_pitch: bool = false  # 是否启用垂直视角旋转
@export var min_pitch: float = -0.3  # 向下看的角度限制（弧度）
@export var max_pitch: float = 0.2   # 向上看的角度限制（弧度）

# 内部变量
var yaw: float = 0.0  # 水平旋转（左右）- 角色的Y轴旋转
var pitch: float = 0.0  # 垂直旋转（上下）- 相机的X轴旋转（可选）

func _ready():
	# 如果没有指定相机，尝试查找子节点中的相机
	if camera == null:
		camera = get_node_or_null("Camera3D")
		# 如果还是没有，尝试在场景中查找
		if camera == null:
			camera = get_viewport().get_camera_3d()
	
	# 如果没有指定目标，尝试查找玩家
	if target == null:
		target = get_tree().get_first_node_in_group("player")
		# 如果还是没有，尝试查找CharacterBody3D
		if target == null:
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				target = players[0]
			else:
				# 尝试查找场景中所有的CharacterBody3D
				var all_nodes = get_tree().get_nodes_in_group("")
				for node in get_tree().get_nodes_in_group(""):
					if node is CharacterBody3D and node != self:
						target = node
						break
	
	# 初始化yaw为目标的当前旋转
	if target:
		yaw = target.rotation.y
		print("ThirdPersonCamera: 目标已设置 - ", target.name)
	else:
		print("ThirdPersonCamera: 警告 - 未找到目标角色！")
	
	if camera:
		print("ThirdPersonCamera: 相机已设置 - ", camera.name)
	else:
		print("ThirdPersonCamera: 警告 - 未找到相机！")
	
	# 捕获鼠标
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("ThirdPersonCamera: 鼠标已捕获")

func _input(event: InputEvent):
	# 处理鼠标移动 - 控制角色旋转（生化危机5风格）
	if event is InputEventMouseMotion:
		# 检查鼠标是否被捕获
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			# 如果鼠标没有被捕获，尝试重新捕获（点击时）
			if event.button_mask != 0:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		
		# 水平旋转（Y轴）- 左右移动鼠标旋转角色朝向
		yaw -= event.relative.x * mouse_sensitivity
		
		# 将旋转应用到目标角色
		if target:
			target.rotation.y = yaw
		else:
			# 即使没有目标，也更新自己的旋转（用于调试）
			rotation.y = yaw
		
		# 垂直旋转（X轴，限制俯仰角）- 可选功能
		if enable_pitch:
			pitch -= event.relative.y * mouse_sensitivity
			pitch = clamp(pitch, min_pitch, max_pitch)
			# 如果相机是子节点，应用俯仰角
			if camera and camera.get_parent() == self:
				camera.rotation.x = pitch
	
	# ESC 键释放/捕获鼠标
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# 点击鼠标左键时捕获鼠标（方便测试）
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:  # 1 = MOUSE_BUTTON_LEFT
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float):
	# 跟随目标（用户已经设置好了相机的相对位置，这里只需要跟随位置和朝向）
	if target:
		# 跟随角色的位置
		global_position = target.global_position
		# 同步角色的Y轴旋转（相机跟随角色朝向）
		rotation.y = target.rotation.y
		
		# 如果相机是子节点，相机会自动跟随父节点的位置和旋转
		# 如果相机在其他位置，需要手动更新位置
		if camera and camera.get_parent() != self:
			# 相机不在当前节点下，需要手动跟随
			# 假设相机已经设置好了相对位置，这里只需要更新朝向
			# 相机应该朝向角色前方
			var look_target = target.global_position + target.transform.basis * Vector3(0, camera_height * 0.3, 5.0)
			camera.look_at(look_target, Vector3.UP)

# 获取角色的朝向（用于玩家移动计算）- 生化危机5风格
func get_character_forward() -> Vector3:
	# 获取角色的前方方向（在XZ平面，忽略Y轴）
	if target:
		var forward = -target.transform.basis.z
		forward.y = 0
		return forward.normalized()
	return Vector3.FORWARD

func get_character_right() -> Vector3:
	# 获取角色的右侧方向（在XZ平面，忽略Y轴）
	if target:
		var right = target.transform.basis.x
		right.y = 0
		return right.normalized()
	return Vector3.RIGHT

