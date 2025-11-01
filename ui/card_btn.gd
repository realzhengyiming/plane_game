extends Button

@onready var upgrade_content: Label = $card_content
@onready var card_title: RichTextLabel = $card_title
@onready var card_face: TextureRect = $card_face

func set_card_content(title:String, content:String, img_name:String):
	# todo 后面也应该改成配置文件来管理不同的东西,不可能字符串写硬代码的
	
	upgrade_content.text = content
	card_title.text = "[wave amp=10 speed=0.3]" + title + "[/wave]"
	# 1. 构建完整路径（假设图片是 PNG 格式，若有其他格式可手动拼接，如".jpg"）
	var full_path = "res://food_imgs/" + img_name + ".png"  # 例如 "res://food_imgs/apple.png"

	# 2. 加载图片资源（使用 load() 同步加载，适合小图标）
	var texture: Texture2D = load(full_path)

	# 3. 错误处理：如果资源不存在，提示并显示默认图标
	if not texture:
		print("警告：图片不存在 - ", full_path)
		# 可选：设置默认图标（需提前准备一张 default.png 放在 food_imgs 中）
		texture = load("res://food_imgs/29_cookies_dish.png")
	card_face.texture = texture  # 换图片
	
	

# 导出变量，在编辑器中关联你的 handraw_style.tres
@export var handraw_material: ShaderMaterial

func _ready() -> void:
	focus_entered.connect(_focus_enter_extend)
	# 可选：失去焦点时恢复原材质
	focus_exited.connect(_focus_exit_restore)

func _focus_enter_extend() -> void:
	print("关注了" + self.name)
	if handraw_material:
		# 应用手绘风格材质
		self.material = null

func _focus_exit_restore() -> void:
	# 恢复默认材质（如果需要）
	self.material = handraw_material  # 或替换为原始材质
