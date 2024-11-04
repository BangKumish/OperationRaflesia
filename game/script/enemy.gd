extends CharacterBody2D
class_name EnemyController

const SPEED = 50
var direction = -1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d_forward: RayCast2D = $CollisionShape2D/RayCast2D_forward
@onready var ray_cast_2d_downward: RayCast2D = $CollisionShape2D/RayCast2D_downward
@onready var area_2d_container: Node2D = $Area2D_Container

var currentHealth = 100
var isDead = false
var isAttacking = false

func  _process(_delta: float) -> void:
	updateAnimation()

func _physics_process(_delta: float) -> void:
	if is_on_floor() == false:
		velocity.y = 300

	if isDead:
		return

	if isAttacking:
		if animated_sprite_2d.is_playing() == false:
			isAttacking = false
		else:
			return

	if ray_cast_2d_forward.is_colliding() || ray_cast_2d_downward.is_colliding() == false:
		direction = -direction
		ray_cast_2d_forward.target_position = -ray_cast_2d_forward.target_position
		ray_cast_2d_downward.position.x = -ray_cast_2d_downward.position.x
		area_2d_container.scale.x = -direction
		
	velocity.x = direction * SPEED
	
	move_and_slide()
	
func updateAnimation():
	if isDead:
		return
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x > 0
	
	if isAttacking == false:
		animated_sprite_2d.play("walk")
	elif animated_sprite_2d.animation != "attack":
		animated_sprite_2d.play("attack")

func applyDamage(damage: int):
	if isDead:
		return
	
	currentHealth -= damage
	
	if currentHealth <= 0:
		isDead = true
		animated_sprite_2d.play("die")
		set_collision_layer_value(3, false)
		await get_tree().create_timer(2).timeout
		queue_free()


func _on_area_2d_player_detector_body_entered(_body: Node2D) -> void:
	isAttacking = true
