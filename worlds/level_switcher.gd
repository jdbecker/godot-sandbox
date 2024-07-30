class_name LevelSwitcher
extends Node

@onready var level: Node = $Level


# Call this function deferred and only on the main authority (server). When
# called, this will remove the current level scene, so we want to call this with
# deferred so that scene has time to clean up. And we only want to call this as
# the server because the server will propagate scene spawning and synchronizing
# to the clients.
func change_level(path: String) -> void:
	# type-check the path
	var resource := load(path)
	assert(resource is PackedScene, "Cannot change_level to a path which isn't a PackedScene!")
	var scene := resource as PackedScene
	
	# Remove old level if any.
	for child in level.get_children():
		level.remove_child(child)
		child.queue_free()
	
	# Add new level.
	#multiplayer_spawner.clear_spawnable_scenes()
	#multiplayer_spawner.add_spawnable_scene(path)
	level.add_child(scene.instantiate())
