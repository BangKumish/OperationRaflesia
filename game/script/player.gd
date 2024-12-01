extends CharacterBody2D
class_name PlayerController

#Const HERE
const SPEED = 150
const JUMP_VELOCITY = -450
const GRAVITY = 1800
var doubleJump

#Import AnimationSptite
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shooting_point: Node2D = $shooting_point

var airborneLastFrame = false

const BURST_SIZE = 7
const SHOOT_DURATION = .125
const BURST_DELAY = 1.275

## EXPERIMENTAL START HERE
const MAG_SIZE = 7
#var ammo_in_mag = MAG_SIZE
## EXPERIMENTAL END HERE

const RELOAD_DURATION = 1.5

#var AMMO = 7

var isShooting = false
var isReloading = false
var burstCount = 0

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
		
var ammo_in_mag = 7:
	set(newValue):
		ammo_in_mag = newValue
		emit_signal("playerBulletUpdated", ammo_in_mag)
		
var AMMO = 7:
	set(newValue):
		AMMO = newValue
		emit_signal("playerAmmoUpdated", AMMO)

signal playerHealthUpdated(newValue, maxValue)
signal playerCoinUpdated(newValue)
signal playerBulletUpdated(newValue)
signal playerAmmoUpdated(newValue)

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
		if ammo_in_mag <= 0:
			if AMMO <= 0:
				melee_attack()
			else:
				reload()
		else:
			tryShoot()
		
	if Input.is_action_just_pressed("reload"):
		reload()
	
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
				if ammo_in_mag <= 0 and AMMO <= 0:
					animated_sprite_2d.play("melee_attack")
				else:
					animated_sprite_2d.play("shoot_stand")
		
			elif isReloading:
				animated_sprite_2d.play("reload")
	
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
	
	## EXPERIMENTAL START HERE
	
	if isShooting or isReloading:
		return
		
	if ammo_in_mag <= 0:
		if AMMO > 0:
			reload()
		else:
			melee_attack()
		return
	
	if ammo_in_mag > 0:
		isShooting = true
		shoot()
		playFireVfx()
	
		ammo_in_mag -= 1
		print("Ammo in Mag: ", ammo_in_mag)
	
		await get_tree().create_timer(SHOOT_DURATION).timeout
		isShooting = false
	
	## EXPERIMENTAL END HERE

## EXPERIMENTAL START HERE

func reload():
	if isReloading or ammo_in_mag == MAG_SIZE:
		return
		
	isReloading = true
	await get_tree().create_timer(RELOAD_DURATION).timeout
	
	var needed_ammo = MAG_SIZE - ammo_in_mag
	var ammo_to_reload = min(needed_ammo, AMMO)
	ammo_in_mag += ammo_to_reload
	AMMO -= ammo_in_mag
	
	print("Reloaded. Ammo in Mag: ", ammo_in_mag, "Remaining ammo: ", AMMO)
	isReloading = false
	
func melee_attack():
	if isShooting or isReloading:
		return
		
	isShooting = true
	animated_sprite_2d.play("melee_attack")
	
	var meleeToSpawn = preload("res://game/scene/melee.tscn")
	var meleeInstance = GameManager.spawnVFX(meleeToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		meleeInstance.direction = -1
	else:
		meleeInstance.direction = 1
	#
	await get_tree().create_timer(0.75).timeout
	isShooting = false
		
## EXPERIMENTAL END HERE

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
			
func collectedAmmo(value: int):
	AMMO += value

func switchToUncontrollable():
	currentState = playerState.uncontrollable
