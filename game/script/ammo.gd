extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var value = 14

func _on_body_entered(body: Node2D) -> void:
	var player = body as PlayerController
	if player:
		player.collectedAmmo(value)
	queue_free()
	
func _process(delta: float) -> void:
	#if sprite_2d.is_playing() == false:
		#queue_free()
	return
