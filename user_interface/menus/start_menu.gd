extends Control

signal hosted(path: String)

@export var level_scene: String

@onready var username_line_edit: LineEdit = %UsernameLineEdit as LineEdit

var _data := Global.data as Data


func _ready() -> void:
	username_line_edit.text = _data.username


func _on_solo_button_pressed() -> void:
	queue_free.call_deferred()
	hosted.emit(level_scene)


func _on_host_button_pressed() -> void:
	Lobby.host_game()
	queue_free.call_deferred()
	hosted.emit(level_scene)


func _on_join_button_pressed() -> void:
	Lobby.join_game("localhost")
	queue_free.call_deferred()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_username_line_edit_text_changed(new_text: String) -> void:
	_data.username = new_text
	_data.save_data()
