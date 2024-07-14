extends Control

const TEST_WORLD := "res://worlds/test_world.tscn"


func _on_solo_button_pressed() -> void:
	get_tree().change_scene_to_file(TEST_WORLD)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
