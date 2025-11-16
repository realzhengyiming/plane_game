@tool
# Card.gd
extends CanvasLayer

#var LineEdit$LineEdit 引用都不会，傻逼了
#@onready var line_edit = $VBoxContainer/LineEdit
# 随机显示三个升级种类, 然后点击了后, 发出升级信号.升级信号要给 用户的角色, 或者 那就是玩家get到. 然后就可以应用升级了
@onready var label = $VBoxContainer/Label
@onready var label2 = $VBoxContainer/Label2
@onready var hbox_container: HBoxContainer = $HBoxContainer

#@onready var center_btn: CardButton = $HBoxContainer/CardButton
#@onready var center_btn2: CardButton = $HBoxContainer/CardButton2
#@onready var center_btn3: CardButton = $HBoxContainer/CardButton3
@export var card_button: PackedScene = preload("res://ui/new_card.tscn")

#signal upgrade_selected(select_strategry: BaseStrategy)  # 改为传递升级类型（而非ID）
@export var available_select_upgrades: Array[BaseStrategy]
var available_upgrades: Array[BaseStrategy]
var buttons: Array[CardButton]

func _ready() -> void:
	# 1. 找到参考节点 SplitContainer
	var split_container = hbox_container.get_node("SplitContainer")
	var split_index = hbox_container.get_children().find(split_container)
	
	if split_index == -1:
		print("错误：HBox中找不到SplitContainer")
		return
	
	# 2. 实例化 CardButton
	for i in range(3):
		var new_card = card_button.instantiate()
		# 3. 插入到 SplitContainer 下方（HBoxContainer 中 SplitContainer 后的第一个位置）
		hbox_container.add_child(new_card)  # 先添加到容器

		buttons.append(new_card)
	buttons[1].grab_focus()
	update_button_texts()
		
	# 4. 初始化 CardButton（假设 CardButton 有 init 方法）
		#center_btn2.grab_focus()  # 关键：主动抢占焦点
		#buttons = [center_btn, center_btn2, center_btn3]  # 假设顺序是：左→中→右
	
	# 获取我某个文件夹下的所有策略资源, 然后随机选3个	
	# 1. 创建数组副本（避免修改原数组）
	var temp_array = available_select_upgrades.duplicate()
	# 2. 打乱顺序（shuffle() 无返回值，单独执行）
	temp_array.shuffle()
	# 3. 截取前3个元素
	available_upgrades = temp_array.slice(0, 3)
		# 假设本次可选升级为：攻击力、生命值、速度（可改为随机选择）
	#available_upgrades = [
		#UpgradeConfig.UpgradeType.ATTACK_SPEED,
		#UpgradeConfig.UpgradeType.HEALTH_UP,
		#UpgradeConfig.UpgradeType.SPEED_UP
	#]
	#update_button_texts()
	#set_process(true)  # 启用 _process 回调

func _process(delta: float) -> void:
	# 延迟一帧执行，确保子节点已初始化
	update_button_texts()
	set_process(false)  # 只执行一次，避免重复调用

func _input(event: InputEvent) -> void:
	# 1. 先过滤：只处理键盘事件，排除鼠标移动、触摸等事件（关键！）
	if not event is InputEventKey:
		return
	
	# 2. 用 Input 类的静态方法判断按键，而非 event（核心修正）
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("a"):
		# A键或左方向键：焦点左移
		move_focus(-1)
	elif Input.is_action_just_pressed("right") or Input.is_action_just_pressed("d"):
		# D键或右方向键：焦点右移
		move_focus(1)


# 3. 核心：移动焦点的逻辑

# 3. 修正：全局获取焦点，计算新焦点按钮
func move_focus(direction: int) -> void:
	# 关键修改：通过 root 全局获取当前焦点节点
	#var current_focus_btn = Input.get_focus_owner()
	var current_focus_btn = get_viewport().gui_get_focus_owner()
	if not current_focus_btn:
		return  # 没有焦点节点，跳过

	# 找到当前焦点按钮在数组中的索引
	var current_index = buttons.find(current_focus_btn)
	if current_index == -1:
		return  # 当前焦点不在按钮数组中（比如点了其他控件），跳过

	# 计算新索引（处理边界：循环切换）
	var new_index = current_index + direction
	# 左移到最左时，跳到最右（循环）
	if new_index < 0:
		new_index = buttons.size() - 1
	# 右移到最右时，跳到最左（循环）
	elif new_index >= buttons.size():
		new_index = 0

	# 让新按钮获取焦点
	buttons[new_index].grab_focus()

# 动态更新按钮文本（显示本次升级的具体数值）
func update_button_texts():
	# 遍历3个可选升级类型

	for i in range(min(buttons.size(), available_upgrades.size())):
		var btn = buttons[i]
		var upgrade = available_upgrades[i]
		# 赋值逻辑...
		# 格式化文本（根据你的实际需求调整，这里保留你的逻辑
		# 直接给当前配对的按钮赋值，无需判断索引
		btn.set_card_content(upgrade)
		#btn.upgrade_content.text = upgrade.desc
		#btn.card_title.text = "[wave amp=10 speed=0.3]" + upgrade.upgrade_name + "[/wave]"
		## 1. 构建完整路径（假设图片是 PNG 格式，若有其他格式可手动拼接，如".jpg"）
		## 可选：设置默认图标（需提前准备一张 default.png 放在 food_imgs 中）
		#btn.card_face.texture = upgrade.texture  # 换图片
		
		btn.pressed.connect(on_selected.bind(available_upgrades[i]))

	pass
	
	# 绑定按钮点击（传递升级类型）
	#center_btn.pressed.connect(on_selected.bind(available_upgrades[0]))
	#center_btn2.pressed.connect(on_selected.bind(available_upgrades[1]))
	#center_btn3.pressed.connect(on_selected.bind(available_upgrades[2]))

func on_selected(upgrade_strategy: BaseStrategy):
	SignalBus.upgrade_selected.emit(upgrade_strategy)  # 直接通过信号总线来发送信号
	print("选择了" + str(upgrade_strategy))
	queue_free()
