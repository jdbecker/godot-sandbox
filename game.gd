extends Node

@onready var level_switcher: LevelSwitcher = $LevelSwitcher

func _on_start_menu_hosted(path: String) -> void:
	level_switcher.change_level.call_deferred(path)
