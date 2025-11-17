class_name BaseStrategy
extends Resource

@export var texture: Texture = preload("res://ui/物品_Items_-_《DOTA2》官方网站/angels_demise_png.png")
@export var upgrade_name: String = "升级的模块的名字"
@export var desc: String = "描述"  # 卡片的作用

func apply_upgrade(bullet: BaseAttribute):
	pass

func apply_to_hit(bullet: BaseAttribute):
	pass # 添加击退效果
