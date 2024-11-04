extends CharacterBody2D
class_name PlayerController

#Const HERE
const SPEED = 180
const JUMP_VELOCITY = -450
const GRAVITY = 1800
var doubleJump

#Import AnimationSptite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_point: Node2D = $shooting_point

var airborneLastFrame = false
var isShooting = false
const SHOOT_DURATION = 0.249

enum playerState {normal, hurt, dead, uncontrollable}
var currentState: playerState = playerState.normal:
	set(newValue):
		currentState = newValue
		match currentState: 
			playerState.hurt:
				if is_on_floor():
					animated_sprite_2d.play("hit_stand")
				else:
					animated_sprite_2d.play("hit_jump")
			playerState.dead:
				animated_sprite_2d.play("die")
				set_collision_layer_value(2, false)
				GameManager.playerIsDead()
			playerState.uncontrollable:
				set_collision_layer_value(2, false)

var currentHealth:
	set(newValue):
		currentHealth = newValue
		emit_signal("playerHealthUpdated", currentHealth, MAX_HEALTH)
const MAX_HEALTH = 100

var currentCoin = 0:
	set(newValue):
		currentCoin = newValue
		emit_signal("playerCoinUpdated", currentCoin)

signal playerHealthUpdated(newValue, maxValue)
signal playerCoinUpdated(newValue)

func _ready() -> void:
	currentHealth = MAX_HEALTH
	GameManager.player = self
	GameManager.playerOriginalPos = position

func _process(_delta: float) -> void:
	updateAnimation()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		doubleJump = true
	
	if is_on_floor() == false:
		velocity.y += GRAVITY * delta
		airborneLastFrame = true
		
		if Input.is_action_just_pressed("jump") and doubleJump == true:
			velocity.y += JUMP_VELOCITY
			playJumpVFX()
			doubleJump = false
	
	elif airborneLastFrame:
		playLandVFX()
		airborneLastFrame = false
		
	if currentState == playerState.hurt || currentState == playerState.dead || currentState == playerState.uncontrollable:
		velocity.x = 0
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		playJumpVFX()
		
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else: 
		velocity.x = 0
		
	if Input.is_action_just_pressed("shoot"):
		tryShoot()
	
	if Input.is_action_just_pressed("down") and is_on_floor():
		position.y += 3
	
	move_and_slide()
	
func updateAnimation():
	if currentState == playerState.dead:
		return
	elif currentState == playerState.hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState = playerState.normal
	
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -26
		else:
			shooting_point.position.x = 26
		
	if is_on_floor():
		if abs(velocity.x) >= 0.1:
			
			var playingAnimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation
			
			if isShooting:
				animated_sprite_2d.play("shoot_run")
				if playingAnimationName == "run":
					animated_sprite_2d.frame = playingAnimationFrame
			else:
				if playingAnimationName == "shoot_run" && animated_sprite_2d.is_playing():
					pass
				else:
					animated_sprite_2d.play("run")
		else:
			if isShooting:
				animated_sprite_2d.play("shoot_stand")
			else:
				animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("jump")
		
		if isShooting:
			animated_sprite_2d.play("shoot_jump")
	
		
func playJumpVFX():
	var vfxToSpawn = preload("res://game/scene/vfx_jump_up.tscn")
	GameManager.spawnVFX(vfxToSpawn, global_position)
	
	
func playLandVFX():
	var vfxToSpawn = preload("res://game/scene/vfx_land.tscn")
	GameManager.spawnVFX(vfxToSpawn, global_position)
	
func shoot():
	var bulletToSpawn = preload("res://game/scene/bullet.tscn")
	var bulletInstance = GameManager.spawnVFX(bulletToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1
	else:
		bulletInstance.direction = 1
		
func tryShoot():
	if isShooting:
		return
		
	isShooting = true
	shoot()
	playFireVfx()
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false

func playFireVfx():
	var vfxToSpawn = preload("res://game/scene/vfx_player_fire.tscn")
	var vfxInstance = GameManager.spawnVFX(vfxToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1

func applyDamage(damage: int):
	print("The Player is Damaged")
	print(damage)
	print(currentHealth)
	
	if currentState == playerState.hurt || currentState == playerState.dead:
		return
		
	currentHealth -= damage
	currentState = playerState.hurt
	
	if currentHealth <= 0:
		currentHealth = 0
		currentState = playerState.dead

func collectedCoin(value: int):
	currentCoin += value
	
	if currentHealth < MAX_HEALTH:
		currentHealth += value * 3
		if currentHealth > MAX_HEALTH:
			currentHealth = MAX_HEALTH

func switchToUncontrollable():
	currentState = playerState.uncontrollable
