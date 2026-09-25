class_name ManaComponent
extends Node

signal mana_updated(new_value: float)

@export var max_mana: float
@export var current_mana: float

func _ready() -> void:
	current_mana = max_mana

func can_spend(amount: float) -> bool:
	if amount <= current_mana:
		return true
	else:
		return false

@rpc("any_peer","call_local","reliable")
func spend_mana(amount: float):
	if multiplayer.is_server():
		current_mana -= amount
		sync_mana.rpc(current_mana)

@rpc("any_peer","call_local","reliable")
func sync_mana(new_amount):
	current_mana = clamp(new_amount, 0, max_mana)
	mana_updated.emit(current_mana)
