extends CPUParticles2D
#@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D


func start_explode():
	one_shot = true
	emitting = true
	print("baozhale")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	#emitting()
	
