extends Node2D


@export var sprite: Sprite2D = null
@export var muzzle: Marker2D = null


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	look_at(get_global_mouse_position())

	if get_global_mouse_position().x < owner.global_position.x:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
