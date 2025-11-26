extends Sprite2D

var original_position: Vector2
var original_scale: Vector2
var talking_tween: Tween

func _ready():
	original_position = position
	original_scale = scale
	start_talking_animation()

func start_talking_animation():
	stop_talking_animation()
	
	talking_tween = create_tween()
	talking_tween.set_loops()
	talking_tween.set_trans(Tween.TRANS_SINE)
	talking_tween.set_ease(Tween.EASE_IN_OUT)
	
	# 顺序执行（效果类似，但更稳定）
	talking_tween.tween_property(self, "position:x", original_position.x - 2, 0.1)
	talking_tween.tween_property(self, "scale", original_scale * 1.02, 0.1)
	
	talking_tween.tween_property(self, "position:x", original_position.x + 2, 0.1)
	talking_tween.tween_property(self, "scale", original_scale * 0.98, 0.1)
	
	talking_tween.tween_property(self, "position:x", original_position.x, 0.1)
	talking_tween.tween_property(self, "scale", original_scale, 0.1)

func stop_talking_animation():
	if talking_tween and talking_tween.is_valid():
		talking_tween.kill()
	
	var return_tween = create_tween()
	return_tween.tween_property(self, "position", original_position, 0.2)
	return_tween.tween_property(self, "scale", original_scale, 0.2)
