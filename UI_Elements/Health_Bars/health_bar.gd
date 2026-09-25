extends Control

@onready var parent: Node3D = get_parent()
@onready var health_bar = $health
@onready var mana_bar = $mana

func _ready() -> void:
	await owner.ready
	parent.health.health_updated.connect(_on_health_updated)
	health_bar.max_value = parent.health.max_health
	_on_health_updated(parent.health.current_health)
	
	if parent is not PlayableCharacter:
		mana_bar.visible = false
	else:
		parent.mana.mana_updated.connect(_on_mana_updated)
		mana_bar.max_value = parent.mana.max_mana
		_on_mana_updated(parent.mana.current_mana)
	
func _process(_delta: float) -> void:
	var current_camera = get_viewport().get_camera_3d()
	
	if current_camera:
		position = current_camera.unproject_position(parent.global_position)

func _on_health_updated(new_value: float):
	health_bar.value = new_value
	if health_bar.value <= 0:
		visible = false

func _on_mana_updated(new_value: float):
	mana_bar.value = new_value
