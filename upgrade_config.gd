# UpgradeGrowthConfig.gd（自动加载脚本，路径：res://configs/UpgradeGrowthConfig.gd）
extends Node

static var IS_TEST_ENV: bool = true

# 升级类型（与之前保持一致）
enum UpgradeType {
	ATTACK_SPEED,    # 攻击速度 改成按着时候就默认发射
	HEALTH_UP,    # 生命值上限
	SPEED_UP,     # 移动速度
}

# 记录每种升级的等级（初始为0，代表未升级过）
var upgrade_levels: Dictionary = {
	UpgradeType.ATTACK_SPEED: 0,
	UpgradeType.HEALTH_UP: 0,
	UpgradeType.SPEED_UP: 0
}

# 成长规则配置：key=升级类型，value=规则详情
# 规则说明：
# - base: 第一次升级的基础值
# - growth_type: 成长类型（"add"=固定增加值, "multiply"=乘法递增, "exponential"=指数增长）
# - growth_value: 成长参数（如每次+2，或每次×1.1） 这种升级的写法也不好用. 可能也是上次哪种模块化的升级会好用一些. 
const GROWTH_RULES = {
	UpgradeType.ATTACK_SPEED: {
		base = 10,    # 第1次升级+5
		growth_type = "+",    # 每次升级额外+2（第2次+7，第3次+9...）
		growth_value = 5
	},
	UpgradeType.HEALTH_UP: {
		base = 5,              # 第1次+20
		growth_type = "+",# 每次升级在之前基础上×1.2（第2次+24，第3次+28.8...）
		growth_value = 1
	},
	UpgradeType.SPEED_UP: {
		base = 10,             # 第1次+20%
		growth_type = "+", # 指数增长（第n次 = base × (1.1)^(n-1)）
		growth_value = 5      # 指数底数
	}
}

# 计算第n次升级的实际值（核心函数）
func calculate_upgrade_value(upgrade_type: int, level: int) -> float:
	var rule = GROWTH_RULES.get(upgrade_type)
	if not rule:
		return 0.0
	
	match rule.growth_type:
		"+":
			# 固定递增：base + (level-1) × growth_value
			return rule.base + (level - 1) * rule.growth_value
		"x":
			# 乘法递增：base × (growth_value)^(level-1)
			return rule.base * pow(rule.growth_value, level - 1)
		"exponential":
			# 指数增长：base × (growth_value)^(level-1)（与乘法逻辑相同，语义区分）
			return rule.base * pow(rule.growth_value, level - 1)
		_:
			return rule.base
