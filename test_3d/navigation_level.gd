@tool
extends NavigationRegion3D
@export var player_scenec: PackedScene
var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	player = player_scenec.instantiate()
	add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# 第一步是读取所有家具的节点, 或者他们的位置?
# 此场景下直接 分组为 furniture的 子节点,  名字即为家具名, 一共有三个. 为了方便, 那就用 1, 2, 3 按钮来作为触发 走到家具1,走到家具2...的触发
# 请帮我补全代码
