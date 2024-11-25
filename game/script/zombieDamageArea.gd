#zombieDamageArea.gd
extends Area2D

@onready var animation_tree: AnimatedSprite2D = $"../../AnimationTree"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

#const START_FRAME = 10
#const END_FRAME = 13
@export var DAMAGE = 15

func _process(_delta: float) -> void:
	if animation_tree.animation == "attack":
		#if animation_tree.frame >= START_FRAME && animation_tree.frame <= END_FRAME:
		monitoring = true
		collision_shape_2d.visible = true
		return
			
	monitoring = false
	collision_shape_2d.visible = false

func _on_body_entered(body: Node2D) -> void:
	var player =  body as PlayerController
	if player:
		player.applyDamage(DAMAGE)
