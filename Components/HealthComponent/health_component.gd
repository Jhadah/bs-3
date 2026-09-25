class_name HealthComponent
extends Node

signal health_updated

@export var max_health: float
var current_health: float:
	set(value):
		current_health = value
		health_updated.emit(value)

func _ready() -> void:
	current_health = max_health

@rpc("any_peer","call_local","reliable")
func take_damage(amount: float):
	if multiplayer.is_server():
		current_health -= amount
		sync_health.rpc(current_health)
		print(current_health)

@rpc("any_peer","call_local","reliable")
func heal(amount: float):
	if multiplayer.is_server():
		current_health += amount
		sync_health.rpc(current_health)
		print(current_health)

@rpc("any_peer","call_local","reliable")
func sync_health(new_hp: float):
	current_health = clamp(new_hp, 0, max_health)
