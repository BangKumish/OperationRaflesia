extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var value = 1

func _on_body_entered(body: Node2D) -> void:
	animated_sprite_2d.play("collected")
	var player = body as PlayerController
	if player:
		player.collectedCoin(value)
	
func _process(delta: float) -> void:
	if animated_sprite_2d.is_playing() == false:
		queue_free()
