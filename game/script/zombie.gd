extends CharacterBody2D
class_name ZombieController

@onready var ray_forward: RayCast2D = $CollisionShape2D/RayForward
@onready var ray_downward: RayCast2D = $CollisionShape2D/RayDownward
@onready var animated_sprite: AnimatedSprite2D = $AnimationTree
@onready var node_2d: Node2D = $Node2D

var direction = 1
@export var SPEED = 50
@export var currentHealth = 100
@export var coinPrize = 5

var isDead = false
var isAttacking = false
var isIdle = false
var isHurt = false

func _process(_delta: float) -> void:
	updateAnimation()

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y = 300

	if isDead or isIdle or isHurt:
		velocity.x = 0
		move_and_slide()
		return

	if isAttacking:
		if not animated_sprite.is_playing():
			isAttacking = false
		else:
			return

	if ray_forward.is_colliding() or not ray_downward.is_colliding():
		#startIdleState()
		direction = -direction
		ray_forward.target_position *= -1
		ray_downward.position.x *= -1
		
		animated_sprite.flip_h = direction < 0
		
		node_2d.scale.x = direction

	velocity.x = direction * SPEED
	move_and_slide()

func updateAnimation():
	if isDead:
		return
		
	if isHurt:
		animated_sprite.play("hurt")
		
	if isIdle:
		animated_sprite.play("idle")
		
	if velocity.x != 0 and not isAttacking:
		animated_sprite.play("walk")
	elif isAttacking and animated_sprite.animation != "attack":
		animated_sprite.play("attack")

func applyDamage(damage: int):
	if isDead:
		return
		
	isHurt = true
	print("Zombie is Damaged")
	print(damage)
	print(currentHealth)
	
	currentHealth -= damage

	if currentHealth <= 0:
		isDead = true
		animated_sprite.play("die")
		set_collision_layer_value(3, false)
		var timer = get_tree().create_timer(.5)
		timer.timeout.connect(queue_free)
		GameManager.getCoin(coinPrize)
		return
		
	animated_sprite.play("hurt")
		
	var hurt_timer = get_tree().create_timer(.25)
	hurt_timer.timeout.connect(_on_hurt_animation_finished)
	
func _on_hurt_animation_finished() -> void:
	isHurt = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	isAttacking = true
