class_name Bullet
extends Area2D


var speed: float = 1000.0


func _physics_process(delta):
	position += transform.x * speed * delta


func _on_body_entered(body):
	if !is_multiplayer_authority():
		return

	if body is Player:
		body.take_damage.rpc_id(body.get_multiplayer_authority())

	destroy.rpc()


@rpc("call_local")
func destroy():
	queue_free()
