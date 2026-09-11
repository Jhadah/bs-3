class_name Entity
extends CharacterBody3D

var entity_id: int

@export var stats: EntityStats

var vfx_library: Dictionary = {}

var current_health: int
var slow_percentage: float = 0.0

func _ready() -> void:
	current_health = stats.max_health

@rpc("any_peer","call_local","reliable")
func take_damage(amount: int):
	if multiplayer.is_server():
		current_health -= amount
		sync_health.rpc(current_health)
		print(current_health)

@rpc("any_peer","call_local","reliable")
func sync_health(new_hp: int):
	current_health = new_hp

@rpc("any_peer","call_local","reliable")
func instantiate_vfx(vfx: String):
	var vfx_scene: Vfx = vfx_library[vfx].instantiate()
	add_child(vfx_scene)
