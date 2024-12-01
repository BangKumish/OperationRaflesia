extends Area2D

var direction = 1
const DAMAGE = 30

@onready var sprite_2d: Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	if direction == -1:
		sprite_2d.flip_h = true
		
func _ready() -> void:
	sprite_2d.flip_h = (direction == -1)
	
	get_tree().create_timer(.25).timeout.connect(queue_free)

func _on_body_entered(body: Node2D) -> void:	
	var enemy = body as EnemyController 
	if enemy:
		enemy.applyDamage(DAMAGE)
	
	var zombie = body as ZombieController
	if zombie:
		zombie.applyDamage(DAMAGE)
	
	queue_free()
