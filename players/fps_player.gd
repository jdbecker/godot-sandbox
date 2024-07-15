class_name Player
extends CharacterBody3D

const TILT_LOWER_LIMIT := -PI/2
const TILT_UPPER_LIMIT := PI/2

@export var SPEED := 10.0
@export_range(0.0, 1.0) var INERTIA := 0.2
@export var JUMP_VELOCITY := 5.0
@export var MOUSE_SENSITIVITY := 0.3

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

var _mouse_input: bool = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3

@onready var camera : Camera3D = $Camera3D as Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true


func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

	if _mouse_input:
		var mouse_motion := event as InputEventMouseMotion
		_rotation_input = -mouse_motion.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -mouse_motion.relative.y * MOUSE_SENSITIVITY
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_update_camera(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction!= Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * SPEED, INERTIA)
		velocity.z = lerp(velocity.z, direction.z * SPEED, INERTIA)
	else:
		if abs(velocity.x) <= 0.1:
			velocity.x = 0.0
		else:
			velocity.x = lerp(velocity.x, 0.0, INERTIA)

		if abs(velocity.z) <= 0.1:
			velocity.z = 0.0
		else:
			velocity.z = lerp(velocity.z, 0.0, INERTIA)
	
	move_and_slide()
	



func _update_camera(delta: float) -> void:
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)

	_mouse_rotation.y += _rotation_input * delta
	
	if is_on_floor():
		_mouse_rotation.y += get_platform_angular_velocity().y * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	camera.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	camera.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
