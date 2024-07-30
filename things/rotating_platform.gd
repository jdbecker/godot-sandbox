extends AnimatableBody3D

@export var rotation_speed := PI/2


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	rotation.y += rotation_speed * delta
