@tool
extends Area2D

@export var item: ItemOrUpgrade:
	set(value):
		item = value
		update_sprite_and_collision()  # 同时更新纹理和碰撞体

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D  # 假设碰撞体节点叫这个名字

func _ready() -> void:
	update_sprite_and_collision()

func update_sprite_and_collision() -> void:
	if not is_inside_tree() or not item or not item.texture:
		return
	
	# 1. 更新 Sprite 纹理
	sprite.texture = item.texture
	
	# 2. 自动调整碰撞体尺寸（基于纹理大小）
	var tex_size = item.texture.get_size()  # 获取纹理尺寸
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = tex_size  # 碰撞体大小设为纹理大小
	collision.shape = rect_shape  # 赋值给碰撞体
