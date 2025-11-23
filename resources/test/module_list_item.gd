extends Control
class_name ModuleListItem

@onready var module_preview: TextureRect = $HBoxContainer/ModulePreview
@onready var count_label: Label = $HBoxContainer/CountLabel

var module_scene: PackedScene
var module_count: int = 0
var editor_ui: ModuleEditorUI = null
var pending_setup: bool = false

func setup(scene: PackedScene, count: int, editor: ModuleEditorUI):
	module_scene = scene
	module_count = count
	editor_ui = editor
	pending_setup = true
	
	# 如果节点已经准备好，立即更新
	if is_inside_tree():
		_update_preview()

func _ready() -> void:
	# 如果setup已经调用过，现在更新预览
	if pending_setup:
		_update_preview()

func _update_preview():
	if not module_preview:
		print("错误：module_preview节点不存在")
		return
	
	# 更新数量标签（先更新，确保显示）
	if count_label:
		count_label.text = "x" + str(module_count)
		print("设置数量标签: x", module_count)
	
	# 创建预览模块
	if not module_scene:
		print("警告：module_scene为空")
		return
	
	# 使用call_deferred确保在下一帧执行，此时所有节点都已准备好
	call_deferred("_load_texture_from_scene")

func _load_texture_from_scene():
	if not module_scene or not module_preview:
		return
	
	# 方法1：尝试直接从场景文件读取texture资源
	# base_module.tscn中texture是 "res://icon.svg"
	var scene_path = module_scene.resource_path
	print("尝试从场景加载texture，场景路径: ", scene_path)
	
	# 对于base_module，我们知道texture是icon.svg，直接加载
	var texture_path = "res://icon.svg"
	var texture = load(texture_path) as Texture2D
	if texture:
		module_preview.texture = texture
		print("✓ 成功加载texture: ", texture_path)
		return
	
	# 方法2：如果直接加载失败，尝试实例化
	print("直接加载失败，尝试实例化...")
	var preview_module = module_scene.instantiate() as BaseBoxModule
	if not preview_module:
		print("警告：无法实例化模块场景")
		return
	
	# 创建一个临时场景来初始化模块
	var temp_parent = Node.new()
	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(temp_parent)
		temp_parent.add_child(preview_module)
		
		# 等待一帧确保所有@onready变量已初始化
		await get_tree().process_frame
		
		# 获取sprite
		var sprite = preview_module.get_node_or_null("Sprite2D")
		if sprite:
			if sprite.texture:
				module_preview.texture = sprite.texture
				print("✓ 成功设置模块预览纹理（从实例）: ", sprite.texture.resource_path if sprite.texture.resource_path else "无路径")
			else:
				print("✗ 警告：Sprite2D的texture为空")
		else:
			print("✗ 警告：模块没有Sprite2D节点")
		
		# 清理
		temp_parent.remove_child(preview_module)
		preview_module.queue_free()
		temp_parent.queue_free()
	else:
		preview_module.queue_free()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if module_count > 0 and editor_ui:
				editor_ui.start_drag_module(module_scene, self)

