extends CharacterBody3D

# 移动速度
@export var move_speed: float = 5.0

# 相机控制器引用（用于获取角色朝向）
@export var camera_controller: ThirdPersonCamera = null

# 生化危机5风格控制方式：
# - 鼠标旋转控制角色朝向
# - WASD相对于角色朝向移动（前进、左、右、后退）

func _ready():
	# 如果没有指定相机控制器，尝试查找
	if camera_controller == null:
		camera_controller = get_tree().get_first_node_in_group("camera_controller")
		if camera_controller == null:
			# 尝试查找ThirdPersonCamera类型的节点
			var cameras = get_tree().get_nodes_in_group("cameras")
			for cam in cameras:
				if cam is ThirdPersonCamera:
					camera_controller = cam
					break

func _physics_process(delta: float):
	# 获取输入方向（使用项目自定义的WASD输入）
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# 如果没有输入，停止移动
	if input_dir.length() == 0:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return
	
	# 获取角色朝向（相对于角色自身的坐标系）
	var forward = -transform.basis.z  # 角色前方
	var right = transform.basis.x      # 角色右侧
	
	# 将Y轴置零，只在水平面移动
	forward.y = 0
	forward = forward.normalized()
	right.y = 0
	right = right.normalized()
	
	# 计算移动方向（相对于角色朝向）
	# input_dir.x: -1左, 1右
	# input_dir.y: -1上(前进), 1下(后退)
	var move_direction = (forward * -input_dir.y) + (right * input_dir.x)
	move_direction = move_direction.normalized()
	
	# 应用移动速度
	velocity.x = move_direction.x * move_speed
	velocity.z = move_direction.z * move_speed
	
	# 应用重力（如果需要）
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	
	# 移动角色
	move_and_slide()
