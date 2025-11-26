extends Node

@export_node_path("Node2D") var owner_node_path: NodePath
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var owner_node: Node2D

func _ready():
	owner_node = get_node_or_null(owner_node_path) as Node2D
	if owner_node:
		create_breathing_animation()
	else:
		push_error("owner_node 未找到: " + str(owner_node_path))

func create_breathing_animation():
	var animation = Animation.new()
	animation.length = 2.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	var track = animation.add_track(Animation.TYPE_VALUE)
	var path = NodePath(str(animation_player.get_path_to(owner_node)) + ":scale")  # ✅ 正确	animation.track_set_path(track, path)
	
	var original_scale = owner_node.scale
	animation.track_insert_key(track, 0.0, original_scale)
	animation.track_insert_key(track, 1.0, original_scale * 1.05)
	animation.track_insert_key(track, 2.0, original_scale)
	
	for i in range(animation.track_get_key_count(track)):
		animation.track_set_key_transition(track, i, 1.0)
	
	animation_player.add_animation("breathing", animation)
	animation_player.play("breathing")
