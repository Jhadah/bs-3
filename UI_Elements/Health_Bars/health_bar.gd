extends Control

@onready var parent: Entity = get_parent()

func _ready() -> void:
	parent.health_updated.connect(_on_health_updated)

func _process(_delta: float) -> void:
	var current_camera = get_viewport().get_camera_3d()
	
	if current_camera:
		position = current_camera.unproject_position(parent.global_position)

func _on_health_updated(new_value: float):
	$TextureProgressBar.value = new_value
	if $TextureProgressBar.value <= 0:
		visible = false
	
