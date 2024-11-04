extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

const START_FRAME = 10
const END_FRAME = 13
@export var DAMAGE = 35

func _process(_delta: float) -> void:
	if animated_sprite_2d.animation == "attack":
		if animated_sprite_2d.frame >= START_FRAME && animated_sprite_2d.frame <= END_FRAME:
			monitoring = true
			collision_shape_2d.visible = true
			return
			
	monitoring = false
	collision_shape_2d.visible = false

func _on_body_entered(body: Node2D) -> void:
	var player = body as PlayerController
	if player:
		player.applyDamage(DAMAGE)
