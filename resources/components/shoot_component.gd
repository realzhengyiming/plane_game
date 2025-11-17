extends Node2D
class_name shot_component

var last_fire_time: float = 0.0
@export var bullet_scene: PackedScene
@export var upgrade_list: Array[BaseStrategy] = []  # 默认为空
#var plane_state: PlaneAttribute
@export var weapon_attr: WeaponAtribute
@onready var shoot_component: Node2D = $shoot_component
@export_node_path("Marker2D") var marker2d_path: NodePath  # 选择节点后存储路径
var spwan_bullet_mark: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.upgrade_selected.connect(add_upgrade_strategies)
	spwan_bullet_mark = get_node(marker2d_path)
	
func add_upgrade_strategies(strategry: BaseStrategy):
	upgrade_list.append(strategry)


func handle_shooting(delta: float) -> void:
	if Input.is_action_pressed("j"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time > last_fire_time + weapon_attr.fire_rate:
			fire_bullet()
			last_fire_time = current_time

# 应用升级（根据类型计算当前等级对应的数值）
func apply_upgrade(upgrade: BaseStrategy) -> void:
	# 升级等级+1
	upgrade_list.append(upgrade)

func fire_bullet() -> void:
	if not bullet_scene:
		return
		
	var bullet = bullet_scene.instantiate()
	if bullet.has_method("setup"):
		#get_parent().get_parent().add_child(bullet)
		get_tree().current_scene.get_parent().add_child(bullet)

		var bullet_position = spwan_bullet_mark.global_position #- Vector2(0, 50)
		#var bullet_position = position - Vdector2(0, 50)
		bullet.setup(bullet_position, Vector2.UP)
		
		for upgrade_obj in upgrade_list:  # todo  有问题, 突然难用起来
			if upgrade_obj is BaseBulletStrategy:
				upgrade_obj.apply_upgrade(bullet.bullet_state)  # 对子弹的属性做升级操作
		#get_parent().add_child(bullet)
		
		# todo 不是子弹, 所以不应该每次发射都升级,而只是需要. 只需要发生改变的时候消耗掉升级?
			#if upgrade_obj is BasePlaneStrategy:
				#upgrade_obj.apply_upgrade(plane_state)  # 对子弹的属性做升级操作


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_shooting(delta)
	
	print("upgrade_list" + str(upgrade_list.size()))
