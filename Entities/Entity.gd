class_name Entity
extends CharacterBody3D

@export var stats: EntityStats

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
