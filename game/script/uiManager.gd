extends CanvasLayer

@onready var health_bar: ProgressBar = $GameScreen/HealthBar
@onready var game_over_screen: Panel = $GameOverScreen
@onready var bullet_label: Label = $GameScreen/BulletLabel
@onready var ammo_label: Label = $GameScreen/AmmoLabel

func _ready() -> void:
	var player = get_tree().get_root().get_node("root").get_node("player") as PlayerController
	player.playerHealthUpdated.connect(updateHealthBar)
	player.playerBulletUpdated.connect(updateBulletLabel)
	player.playerAmmoUpdated.connect(updateAmmoLabel)
	
	GameManager.gameOver.connect(showGameOverScreen)
	
	updateBulletLabel(player.ammo_in_mag)
	updateAmmoLabel(player.AMMO)
	
	game_over_screen.visible = false

func updateHealthBar(newValue: int, maxValue:int):
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue
	
func updateBulletLabel(newValue: int):
	bullet_label.text = str(newValue)

func updateAmmoLabel(newValue: int):
	ammo_label.text = str(newValue)

func showGameOverScreen():
	game_over_screen.visible = true

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
