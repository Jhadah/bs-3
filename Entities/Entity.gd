class_name Entity
extends CharacterBody3D

signal health_updated

var entity_id: int

@export var stats: EntityStats

var vfx_library: Dictionary = {}

var dir: Vector3
var current_health: int
var slow_percentage: float = 0.0
var speed_buff_percentage: float = 0.0

func _ready() -> void:
	current_health = stats.max_health

@rpc("any_peer","call_local","reliable")
func take_damage(amount: int):
	if multiplayer.is_server():
		current_health -= amount
		sync_health.rpc(current_health)
		print(current_health)
@rpc("any_peer","call_local","reliable")
func heal(amount: int):
	if multiplayer.is_server():
		current_health += amount
		sync_health.rpc(current_health)
		print(current_health)

@rpc("any_peer","call_local","reliable")
func sync_health(new_hp: int):
	current_health = clamp(new_hp, 0, stats.max_health)
	health_updated.emit(current_health)
	if current_health <= 0:
		die()

@rpc("any_peer","call_local","reliable")
func instantiate_vfx(vfx: String, anchor: String):
	var vfx_scene: Vfx = vfx_library[vfx].instantiate()
	var parent = get_node("Hitboxes/" + anchor)
	parent.add_child(vfx_scene)
	return vfx_scene

func die():
	if self is PlayableCharacter:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:  #per minion etc
		queue_free()
