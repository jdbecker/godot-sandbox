class_name PauseMenu
extends Control

signal resumed

var _main_menu: String = ProjectSettings.get_setting("application/run/main_scene")
var _previous_mouse_mode: Input.MouseMode

@onready var panel_container: PanelContainer = $PanelContainer as PanelContainer


func _ready() -> void:
	panel_container.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		panel_container.show()
		_previous_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()


func _on_resume_button_pressed() -> void:
	resumed.emit()
	Input.mouse_mode = _previous_mouse_mode
	panel_container.hide()


func _on_start_menu_button_pressed() -> void:
	Lobby.end_connection()
	get_tree().change_scene_to_file(_main_menu)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
