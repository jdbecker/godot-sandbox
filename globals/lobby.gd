extends Node

# this number is arbitrary, I just like it
const PORT := 7677

# returns all player ids (local and remote)
var player_ids: Array[int]: get = _get_player_ids

# used to prevent the game from hanging while creating upnp host
var _join_code_thread: Thread


func _ready() -> void:
	# use offline multiplayer peer by default
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	
	# connect client-only callbacks to clear multiplayer peer if join fails or
	# if server disconnects unexpectedly.
	multiplayer.connection_failed.connect(func() -> void:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new())
	multiplayer.server_disconnected.connect(func() -> void:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new())
	
	# Automatically start the server if app started in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		host_game.call_deferred()


# call to start a hosting a session
func host_game() -> void:
	# create and start the server itself
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT)
	assert(error == Error.OK, "Error attempting to create server: %s" % error)
	assert(
		peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED,
		"Failed to start multiplayer server."
	)
	multiplayer.multiplayer_peer = peer
	
	# connect to router via UPNP using a separate thread so it doesn't hang the
	# client
	_join_code_thread = Thread.new()
	_join_code_thread.start(_upnp_setup)


# call to intentionally disable connection as either host or client
func end_connection() -> void:
	# switch to offline peer (de-referencing the previous peer causes it to get
	# cleaned up by garbage collection, disconnecting everyone connected
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


# call to join a remote host
func join_game(address: String) -> void:
	# default address if empty (helps a ton with debugging)
	if address.is_empty():
		address = "localhost"
	
	# join server by creating a matching peer instance and creating on it a
	# client pointing to the given port and address.
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, PORT)
	assert(error == Error.OK, "Error attempting to join: %s" % error)
	assert(
		peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED,
		"Failed to start multiplayer client."
	)
	multiplayer.multiplayer_peer = peer


# returns all player ids (local and remote), as opposed to
# multiplayer.get_peers() which only returns remote player ids
func _get_player_ids() -> Array[int]:
	var ids := [multiplayer.get_unique_id()] as Array[int]
	for id in multiplayer.get_peers():
		ids.append(id)
	return ids


# avoid having to port-forward by using the router's UPNP (will not work if not supported by router)
func _upnp_setup() -> String:
	var upnp := UPNP.new()
	var discover_result := upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	var map_result := upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)
	var ip := upnp.query_external_address()
	print("Hosting success! Join Address: %s" % ip)
	return ip
