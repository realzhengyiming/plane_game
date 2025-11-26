extends Node2D

@export var enemy_scene: PackedScene  # 敌人场景引用
@export var spawn_interval: float = 1.0  # 生成间隔（秒）
@export var spawn_y_position: float = -0  # 生成Y坐标（屏幕外上方）
# 引用计分板节点（在编辑器中拖入赋值）
@export var score_label: Label  # 拖拽场景中的ScoreLabel到这里
@export var upgrade_ui_scene: PackedScene  # 升级界面,全部都是要用的时候再创建,不错不错
@export var gameover_ui: PackedScene  # 升级界面,全部都是要用的时候再创建,不错不错
@export var player_scene: PackedScene
@onready var boss_progress_bar: ProgressBar = $player_state/boss出现时间

@export var boss_scene:PackedScene

# 所有的属性的显示,能不能动态创建啊
@onready var player_state_ui: VBoxContainer = $player_state

var player : Area2D = null  # 后赋值

var timer: float = 0.0
var ui_score: int = 0.0
var spwan_flag: bool = true

func _ready() -> void:
	print("=== 新游戏场景初始化 _ready 执行 ===")  # 新增日志

	boss_progress_bar.max_value = 35
	boss_progress_bar.value = 35
	
	player = player_scene.instantiate()
	player.position = get_player_spawn_position(player)
	# 放置到屏幕下方的中间位置
	add_child(player)

	player.player_die_signal.connect(open_game_over_ui)  # 死了就打开gameoverr
	player.player_state_changed.connect(_update_all_ui_label)  # 玩家属性变化,直接监听好
	player.send_state_update_signal()  # 手动触发发现一次信号
	#print("player_state_ui 是否存在：", player_state_ui != null)  # 应输出 true
	#print("max_health 子节点是否存在：", player_state_ui.has_node("max_health"))  # 应输出 true
	##print(player_state_ui.get_node("max_health").text )
	#pass
	
	
func _update_all_ui_label(state: PlaneAttribute, var_name):
	player_state_ui.get_node("max_health").text = "max_health:" + str(state.max_health)
	player_state_ui.get_node("current_health").text = "current_health:" + str(state.current_health)
	player_state_ui.get_node("move_speed").text = "move_speed:" + str(state.move_speed)
	#player_state_ui.get_node("bullet_speed").text = "bullet_speed:" + str(state.bullet_speed)
	#player_state_ui.get_node("fire_rate").text = "fire_rate:" + str(state.fire_rate)
	pass
	
	
func upgrade_select(player, upgrade_type: BaseStrategy):
	player.apply_upgrade(upgrade_type)
	print("升级完毕")

func get_player_spawn_position(player: Area2D) -> Vector2:
	var screen_size = get_viewport_rect().size
	var player_size = Vector2(50, 50)  # 默认尺寸（防止出错）

	# 1. 找到 Area2D 下的 CollisionShape2D 子节点（必选，否则碰撞必须有）
	var collider = player.get_node_or_null("CollisionShape2D")
	if collider and collider.shape:
		# 2. 根据碰撞形状获取尺寸（只处理最常见的矩形和圆形）
		if collider.shape is RectangleShape2D:
			# 矩形：extents 是半宽/半高，所以 ×2 得到实际尺寸
			player_size = collider.shape.extents * 2 * player.scale
		elif collider.shape is CircleShape2D:
			# 圆形：直径 = 半径 × 2
			player_size = Vector2(collider.shape.radius * 2, collider.shape.radius * 2) * player.scale

	# 3. 计算下方中间位置
	return Vector2(
		screen_size.x / 2,
		screen_size.y - player_size.y / 2  # 底部贴屏幕
	)



# 显式定义的回调函数：恢复游戏
func _on_upgrade_ui_closed():
	get_tree().paused = false

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		spawn_enemy()
		timer = 0.0

func spawn_enemy() -> void:
	if not enemy_scene or not score_label:
		return
	
	if spwan_flag != true:
		return  # false 就不生成小兵了
	
	var enemy = enemy_scene.instantiate() as Area2D
	enemy.position.y = spawn_y_position
	get_node("enemies").add_child(enemy)
	enemy.name = "enemy:" + enemy.name

	enemy.enemy_destroyed.connect(score_label.add_score)
	enemy.enemy_destroyed.connect(add_score)
	print("score_label score: " + str(score_label.score))


func add_score():
	ui_score += 1
	if ui_score % 5  == 0:  # 这样写也很搞笑,是不是也应该用其他写法,或者状态机
		print("达到了升级次数")
		print(score_label.score)
		print(score_label.score % 10)
		print()
		pass
		get_tree().paused = true
		var upgrade_ui = upgrade_ui_scene.instantiate()
		SignalBus.upgrade_selected.connect(upgrade_select.bind(player))

		add_child(upgrade_ui)
		# 升级界面关闭后恢复游戏（可在upgrade_ui的queue_free前发送信号）
		upgrade_ui.tree_exiting.connect(_on_upgrade_ui_closed)

func open_game_over_ui():
	var game_over_ui = gameover_ui.instantiate()  # todo 场景之间的切换逻辑, UI 的借还逻辑应该是怎么 养的呢
	add_child(game_over_ui)


func _finish_small_enemy_time() -> void:
	spwan_flag = false  # 不再生成小兵
	
	pass # Replace with function body.
	var boss = boss_scene.instantiate()
	get_tree().get_root().add_child(boss)
	var viewport_rect = get_viewport_rect()
	var screen_width = viewport_rect.size.x
	var screen_height = viewport_rect.size.y

	# 3. 计算 Boss 的目标位置
	var target_x = screen_width / 2  # 水平中间（屏幕宽的一半）
	# 垂直位置：屏幕高的 1/4（确保在 1/3 上方，可按需调整比例，比如 1/5、1/3）
	var target_y = screen_height / 4  

	# 4. 设置 Boss 的全局位置（用 global_position 确保坐标正确）
	boss.global_position = Vector2(target_x, target_y)


func _on_per_second_timeout() -> void:
	pass # Replace with function body.
	boss_progress_bar.value -= 1
