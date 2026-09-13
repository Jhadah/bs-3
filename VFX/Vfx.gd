class_name Vfx
extends AnimatedSprite3D

var fixed_rotation: Vector3

func _ready() -> void:
	play("default")
	animation_finished.connect(queue_free)
