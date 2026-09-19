class_name Structure
extends StaticBody3D

signal health_updated

@export var stats: StructureStats
var current_health: float

func _ready() -> void:
	current_health = stats.max_health
	health_updated.emit(current_health)

@rpc("any_peer","call_local","reliable")
func take_damage(amount: int):
	if multiplayer.is_server():
		current_health -= amount
		sync_health.rpc(current_health)
		print(current_health)

@rpc("any_peer","call_local","reliable")
func sync_health(new_hp: int):
	current_health = clamp(new_hp, 0, stats.max_health)
	health_updated.emit(current_health)
	#if current_health <= 0:
		#die()
