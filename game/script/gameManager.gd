extends Node

var player: PlayerController
var playerOriginalPos

#EXPERIMENTAL
var ghulwan: GhulwanController
var ghulwanOriginalPos

signal gameOver()

func playerEnteredDeathZone():
	player.position = playerOriginalPos
	
	#EXPERIMENTAL
	#ghulwan.position = ghulwanOriginalPos
	
func spawnVFX(vfxToSpawn: Resource, position: Vector2):
	var vfxInstance = vfxToSpawn.instantiate()
	vfxInstance.global_position = position
	get_tree().get_root().get_node("root").add_child(vfxInstance)
	
	return vfxInstance

func playerIsDead():
	emit_signal("gameOver")

func playerEnteredEndDoor():
	player.switchToUncontrollable()
	
	#EXPERIMENTAL
	ghulwan.switchToUncontrollable()
	
	emit_signal("gameOver")

func getCoin(value: int):
	player.collectedCoin(value)
	
	#EXPERIMENTAL
	#ghulwan.collectedCoin(value)
	
