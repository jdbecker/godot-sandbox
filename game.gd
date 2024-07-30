extends Node

@onready var level_switcher: LevelSwitcher = $LevelSwitcher
const TEST_WORLD = preload("res://worlds/test_world.tscn")

func _on_start_menu_hosted(path: String) -> void:
	level_switcher.change_level.call_deferred(path)
