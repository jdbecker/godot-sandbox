extends AnimatableBody3D

@export var rotation_speed := PI/4


func _physics_process(delta: float) -> void:
	rotation.y += rotation_speed * delta
