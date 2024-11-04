extends CanvasLayer

@onready var health_bar: ProgressBar = $GameScreen/HealthBar
@onready var coin_label: Label = $GameScreen/CoinLabel
@onready var game_over_screen: Panel = $GameOverScreen

func _ready() -> void:
	var player = get_tree().get_root().get_node("root").get_node("player") as PlayerController
	player.playerHealthUpdated.connect(updateHealthBar)
	player.playerCoinUpdated.connect(updateCoinLabel)
	
	GameManager.gameOver.connect(showGameOverScreen)
	
	game_over_screen.visible = false

func updateHealthBar(newValue: int, maxValue:int):
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue
	
func updateCoinLabel(newValue: int):
	coin_label.text = str(newValue)

func showGameOverScreen():
	game_over_screen.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
