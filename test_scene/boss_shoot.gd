extends Node2D
@export var bullet_scene: PackedScene
@onready var spwan_bullet_mark: Marker2D = $Marker2D
@onready var shot_timer: Timer = $shot_timer
@onready var rotate_timer: Timer = $rotate_timer
@onready var spwan_direct: Vector2 = Vector2.DOWN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("服务启动了")
	pass # Replace with function body.
	shot_timer.autostart = true
	shot_timer.timeout.connect(fire_bullet)
	rotate_timer.autostart = true
	rotate_timer.timeout.connect(rotate_marker2d)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func rotate_marker2d():
	spwan_direct = spwan_direct.rotated(rad_to_deg(10))
	#spwan_bullet_mark.rotate(10)
	pass


func fire_bullet() -> void:
	print("超时了")
	if not bullet_scene:
		print("havnt setup bullet scene")
		return
		
	var bullet = bullet_scene.instantiate()
	if bullet.has_method("setup"):
		#get_parent().get_parent().add_child(bullet)
		get_tree().current_scene.get_parent().add_child(bullet)

		var bullet_position = spwan_bullet_mark.global_position #- Vector2(0, 50)
		#var bullet_position = position - Vdector2(0, 50)
		bullet.setup(bullet_position, spwan_direct)
