extends Node


const PLAYER_SCENE: PackedScene = preload("uid://ccp7a5trw734p")


@export var gui: CanvasLayer = null
@export var arena: TileMapLayer = null
@export var spawner: MultiplayerSpawner = null
@export var online_id_label: Label = null
@export var online_id_prompt: LineEdit = null

var peer = NodeTunnelPeer.new()
var players: Array[Player] = []


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.multiplayer_peer = peer

	peer.connect_to_relay("relay.nodetunnel.io", 9998)
	await peer.relay_connected
	online_id_label.text = peer.online_id

	spawner.spawn_function = add_player


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		peer.leave_room()

		for p in players:
			if p and p.is_inside_tree():
				p.queue_free()
		players.clear()

		arena.hide()
		gui.visible = true


func _on_peer_disconnected(pid: int) -> void:
	print("Peer " + str(pid) + " has left the game!")

	var to_remove : Player = null
	for p in players:
		if p.name.to_int() == pid:
			to_remove = p
			break

	if to_remove:
		if to_remove.is_inside_tree():
			to_remove.queue_free()
		players.erase(to_remove)


func _on_host_pressed() -> void:
	peer.host()
	await peer.hosting

	DisplayServer.clipboard_set(peer.online_id)

	multiplayer.peer_connected.connect(
		func(pid: int):
			print("Peer " + str(pid) + " has joined the game!")
			spawner.spawn(pid)
	)

	spawner.spawn(multiplayer.get_unique_id())
	arena.visible = true
	gui.hide()


func _on_join_pressed() -> void:
	peer.join(online_id_prompt.text)
	await peer.joined

	arena.visible = true
	gui.hide()


func add_player(pid: int) -> Player:
	var player_instance: Player = PLAYER_SCENE.instantiate()

	player_instance.name = str(pid)
	player_instance.global_position = arena.get_child(players.size()).global_position
	players.append(player_instance)

	return player_instance


func get_random_spawnpoint() -> Vector2:
	return arena.get_children().pick_random().global_position
