extends Control

@onready var parent = get_parent()
#@export var camera: Camera3D

func _process(delta: float) -> void:
	#position = camera.unproject_position(parent.global_position)
	var current_camera = get_viewport().get_camera_3d()
	
	if current_camera:
		position = current_camera.unproject_position(parent.global_position)
