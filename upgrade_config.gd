# UpgradeGrowthConfig.gd（自动加载脚本，路径：res://configs/UpgradeGrowthConfig.gd）
extends Node

static var IS_TEST_ENV: bool = false #true
static var IS_ENEMY:String = "enemy"
static var IS_PLAYER:String = "player"


func get_top_level_active_states(root: Node) -> String:
	var active_states = []
	# 检查根节点是否有效
	if not is_instance_valid(root):
		return ""

	# 仅遍历根节点的直接子节点（一层）
	for child in root.get_children():
		# 筛选类型为StateChartState且处于激活状态的节点
		if child is StateChartState and child.active:
			active_states.append(child.name)  # 只返回名称，如需完整节点可改为append(child)

	if active_states.is_empty():
		return ""
	return active_states[0]
