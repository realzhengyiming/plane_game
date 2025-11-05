extends Button

@onready var upgrade_content: Label = $card_content
@onready var card_title: RichTextLabel = $card_title
@onready var card_face: TextureRect = $card_face
@export var upspeed_strategy: BaseStrategy #UpgradeBulletSpeedStrategy

func set_card_content(upgrade: BaseStrategy):
	# todo 后面也应该改成配置文件来管理不同的东西,不可能字符串写硬代码的
	upgrade_content.text = upgrade.desc
	card_title.text = "[wave amp=10 speed=0.3]" + upgrade.upgrade_name + "[/wave]"
	# 1. 构建完整路径（假设图片是 PNG 格式，若有其他格式可手动拼接，如".jpg"）
		# 可选：设置默认图标（需提前准备一张 default.png 放在 food_imgs 中）
	card_face.texture = upgrade.texture  # 换图片
	
	

# 导出变量，在编辑器中关联你的 handraw_style.tres
@export var handraw_material: ShaderMaterial

func _ready() -> void:
	focus_entered.connect(_focus_enter_extend)
	# 可选：失去焦点时恢复原材质
	focus_exited.connect(_focus_exit_restore)
	#var upspeed_strategy = 
	set_card_content(upspeed_strategy)

func _focus_enter_extend() -> void:
	print("关注了" + self.name)
	if handraw_material:
		# 应用手绘风格材质
		self.material = null

func _focus_exit_restore() -> void:
	# 恢复默认材质（如果需要）
	self.material = handraw_material  # 或替换为原始材质
