extends Control

@onready var parent: Node3D = get_parent()
@onready var health_bar = $TextureProgressBar

func _ready() -> void:
	parent.health_updated.connect(_on_health_updated)
	health_bar.max_value = parent.stats.max_health
	
func _process(_delta: float) -> void:
	var current_camera = get_viewport().get_camera_3d()
	
	if current_camera:
		position = current_camera.unproject_position(parent.global_position)

func _on_health_updated(new_value: float):
	health_bar.value = new_value
	if health_bar.value <= 0:
		visible = false
	
