class_name Player
extends CharacterBody2D


const BULLET_SCENE: PackedScene = preload("uid://daelk2mg0nk5a")

const MAX_HEALTH: int = 5
const SPEED: float = 300.0
const ACCELERATION: float = 2000.0
const JUMP_STRENGTH: float = -500.0
const GRAVITY: float = 1000.0


@export var sprite: Sprite2D = null
@export var gun: Node2D = null

var health: int = MAX_HEALTH
var direction: float = 0.0


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))


func _ready() -> void:
	sprite.modulate = Color.BLUE if is_multiplayer_authority() else Color.RED


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("shoot"):
		shoot.rpc(multiplayer.get_unique_id())

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_STRENGTH

	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0.0:
		velocity.y = JUMP_STRENGTH / 4.0

	direction = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)

	move_and_slide()


@rpc("call_local")
func shoot(shooter_pid: int):
	var bullet_instance: Bullet = BULLET_SCENE.instantiate()

	bullet_instance.set_multiplayer_authority(shooter_pid)
	get_parent().add_child(bullet_instance)
	bullet_instance.transform = gun.muzzle.global_transform


@rpc("any_peer")
func take_damage() -> void:
	health -= 1

	if health <= 0:
		health = MAX_HEALTH
		global_position = get_parent().get_random_spawnpoint()
