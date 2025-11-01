# Card.gd
extends CanvasLayer

#var LineEdit$LineEdit 引用都不会，傻逼了
#@onready var line_edit = $VBoxContainer/LineEdit
@onready var label = $VBoxContainer/Label
@onready var label2 = $VBoxContainer/Label2
@onready var center_btn = $HBoxContainer/Card
@onready var center_btn2 = $HBoxContainer/Card2
@onready var center_btn3 = $HBoxContainer/Card3

signal upgrade_selected(upgrade_type: int)  # 改为传递升级类型（而非ID）
var available_upgrades: Array[int] = []
var buttons: Array[Button] = []

func _ready() -> void:
	center_btn2.grab_focus()  # 关键：主动抢占焦点
	buttons = [center_btn, center_btn2, center_btn3]  # 假设顺序是：左→中→右

	#center_btn.text = "选择中间的能力"
	#center_btn2.text = "选择向左的能力"
	#center_btn3.text = "选择向右的能力"
	
		# 假设本次可选升级为：攻击力、生命值、速度（可改为随机选择）
	available_upgrades = [
		UpgradeConfig.UpgradeType.ATTACK_SPEED,
		UpgradeConfig.UpgradeType.HEALTH_UP,
		UpgradeConfig.UpgradeType.SPEED_UP
	]
	update_button_texts()


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
	for i in range(3):
		var upgrade_type = available_upgrades[i]
		var current_level = UpgradeConfig.upgrade_levels[upgrade_type]
		# 计算下次升级（current_level + 1）的数值
		var add_value = UpgradeConfig.calculate_upgrade_value(upgrade_type, current_level + 1)
		
		# 格式化文本（根据类型显示整数或百分比）
		var text = ""
		var title = "属性增强"
		var img_name = ""

		match upgrade_type:
			UpgradeConfig.UpgradeType.ATTACK_SPEED:
				text = "攻击速度 +%d" % add_value
				img_name = "53_gingerbreadman_dish"
			UpgradeConfig.UpgradeType.HEALTH_UP:
				text = "生命值 +%d" % add_value
				img_name = "51_giantgummybear_dish"
				
			UpgradeConfig.UpgradeType.SPEED_UP:
				img_name = "98_sushi_dish"
				
				text = "速度 +%.0f%%" % (add_value * 100)
		
		# 赋值给按钮
		if i == 0: 
			center_btn.set_card_content(title, text, img_name)
		elif i == 1: 
			center_btn2.set_card_content(title, text, img_name)
		elif i == 2: 
			center_btn3.set_card_content(title, text, img_name)
	
	# 绑定按钮点击（传递升级类型）
	center_btn.pressed.connect(on_selected.bind(available_upgrades[0]))
	center_btn2.pressed.connect(on_selected.bind(available_upgrades[1]))
	center_btn3.pressed.connect(on_selected.bind(available_upgrades[2]))

func on_selected(upgrade_type: int):
	upgrade_selected.emit(upgrade_type)
	print("选择了" + str(upgrade_type))
	queue_free()
