extends Control

@export var level_scene: PackedScene

@onready var username_line_edit: LineEdit = %UsernameLineEdit as LineEdit

var _data := Global.data as Data


func _ready() -> void:
	username_line_edit.text = _data.username


func _on_solo_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_username_line_edit_text_changed(new_text: String) -> void:
	_data.username = new_text
	_data.save_data()
