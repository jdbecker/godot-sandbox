class_name PauseMenu
extends Control

signal resumed

const START_MENU := "res://user_interface/menus/start_menu.tscn"


func _on_resume_button_pressed() -> void:
	resumed.emit()
	queue_free()


func _on_start_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(START_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
