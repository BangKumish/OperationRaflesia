extends Area2D

@onready var bullet_sprite_2d: Sprite2D = $Bullet_Sprite2D

const SPEED = 500
var direction = 1
const DAMAGE = 30

func _physics_process(delta: float) -> void:
	if direction == -1:
		bullet_sprite_2d.flip_h = true
		
	position.x += SPEED * direction * delta  

func _on_body_entered(body: Node2D) -> void:
	var vfxToSpawn = preload("res://game/scene/vfx_bullet.tscn")
	var vfxInstance = GameManager.spawnVFX(vfxToSpawn, global_position)
	
	if direction == -1:
		vfxInstance.scale.x = -1
	
	var enemy = body as EnemyController 
	if enemy:
		enemy.applyDamage(DAMAGE)
	
	var zombie = body as ZombieController
	if zombie:
		zombie.applyDamage(DAMAGE)
	
	queue_free()
