class_name Vfx
extends AnimatedSprite3D

var fixed_rotation: Vector3

func _ready() -> void:
	top_level= true
	play("default")
	animation_finished.connect(queue_free)

#func _physics_process(delta: float) -> void:
	#rotation = fixed_rotation
