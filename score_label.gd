extends Label

var score: int = 0  # 初始分数

func _ready() -> void:
	text = "Score: " + str(score)  # 初始化显示

# 3. 定义响应信号的函数：分数+1并更新显示
func add_score() -> void:
	score += 1
	text = "Score: " + str(score)  # 更新Label文本
