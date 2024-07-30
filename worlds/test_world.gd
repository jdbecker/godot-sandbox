extends Node3D

const FPS_PLAYER = preload("res://players/fps_player.tscn")
const ROTATING_PLATFORM = preload("res://things/rotating_platform.tscn")


func _ready() -> void:
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player(1)
	
	if is_multiplayer_authority():
		add_child(ROTATING_PLATFORM.instantiate(), true)


func _add_player(player_id: int) -> void:
	if is_multiplayer_authority():
		var player := FPS_PLAYER.instantiate() as FPSPlayer
		player.name = str(player_id)
		player.position = Vector3(0, 2, 0)
		add_child(player, true)


func _remove_player(player_id: int) -> void:
	if is_multiplayer_authority():
		for child: Node in get_children():
			var player := child as FPSPlayer
			if player:
				if player.get_multiplayer_authority() == player_id:
					player.queue_free()
