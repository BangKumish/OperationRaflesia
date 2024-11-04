extends Node

var player: PlayerController
var playerOriginalPos

signal gameOver()

func playerEnteredDeathZone():
	player.position = playerOriginalPos
	
func spawnVFX(vfxToSpawn: Resource, position: Vector2):
	var vfxInstance = vfxToSpawn.instantiate()
	vfxInstance.global_position = position
	get_tree().get_root().get_node("root").add_child(vfxInstance)
	
	return vfxInstance

func playerIsDead():
	emit_signal("gameOver")

func playerEnteredEndDoor():
	player.switchToUncontrollable()
	emit_signal("gameOver")
