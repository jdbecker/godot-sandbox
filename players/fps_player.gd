class_name FPSPlayer
extends CharacterBody3D

const TILT_LOWER_LIMIT := -PI/2
const TILT_UPPER_LIMIT := PI/2

@export var speed := 10.0
@export_range(0.0, 1.0) var inertia := 0.2
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.3

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float

var _mouse_input: bool = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _player_rotation: Vector3
var _camera_rotation: Vector3
var _data: Data = Global.data

@onready var camera : Camera3D = $Camera3D as Camera3D
@onready var label_3d: Label3D = $Label3D as Label3D


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	print("%s spawned a player character for %s" % [multiplayer.get_unique_id(), name])
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true
		
		label_3d.text = _data.username
		label_3d.hide()


func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

	if _mouse_input:
		var mouse_motion := event as InputEventMouseMotion
		_rotation_input = -mouse_motion.relative.x * mouse_sensitivity
		_tilt_input = -mouse_motion.relative.y * mouse_sensitivity
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_update_camera(delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction!= Vector3.ZERO:
		velocity.x = lerp(velocity.x, direction.x * speed, inertia)
		velocity.z = lerp(velocity.z, direction.z * speed, inertia)
	else:
		if abs(velocity.x) <= 0.1:
			velocity.x = 0.0
		else:
			velocity.x = lerp(velocity.x, 0.0, inertia)

		if abs(velocity.z) <= 0.1:
			velocity.z = 0.0
		else:
			velocity.z = lerp(velocity.z, 0.0, inertia)
	
	move_and_slide()
	
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if collision.get_collider() is RigidBody3D:
			var rigidBody: RigidBody3D = collision.get_collider() as RigidBody3D
			var push_force: float = float(1) + abs(velocity.length())
			rigidBody.apply_central_impulse(-collision.get_normal() * push_force)


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
