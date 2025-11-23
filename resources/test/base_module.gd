extends Node2D
class_name BaseBoxModule
# 它有四个模块, 可以通过拖拽, 增加或者删除模块组合
@onready var sub_modules: Node2D = $sub_modules
@export var sub_modules_list: Array[BaseBoxModule]
enum Direction { UP, DOWN, LEFT, RIGHT }

func append_module_to_direction(module: BaseBoxModule, direction:Direction):
	sub_modules.append()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
