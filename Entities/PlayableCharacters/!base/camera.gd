extends Camera3D

@onready var parent: PlayableCharacter = get_parent()
@onready var camera_offset: Vector3 = global_position #così praticamente lo modifico dall'editor

func _process(_delta: float) -> void:
	global_position = parent.global_position + camera_offset
