class_name EffectComponent
extends Node

signal expired(effect: Effect)

signal speed_changed
signal movement_blocks_changed
signal rotation_blocks_changed

var speed_buffs: Array[Effect]
var speed_debuffs: Array[Effect]
var movement_blocks: Array[Effect]
var rotation_blocks: Array[Effect]

func apply_effect(effect: Effect):
	match effect.type:
		Effect.Type.SPEED_BUFF:
			_apply_effect_helper(effect, speed_buffs, speed_changed)
		Effect.Type.SPEED_DEBUFF:
			_apply_effect_helper(effect, speed_debuffs, speed_changed)
		Effect.Type.MOVEMENT_BLOCK:
			_apply_effect_helper(effect, movement_blocks, movement_blocks_changed)
		Effect.Type.ROTATION_BLOCK:
			_apply_effect_helper(effect, rotation_blocks, rotation_blocks_changed)

func remove_effect(effect: Effect):
	match effect.type:
		Effect.Type.SPEED_BUFF:
			_remove_effect_helper(effect, speed_buffs, speed_changed)
		Effect.Type.SPEED_DEBUFF:
			_remove_effect_helper(effect, speed_debuffs, speed_changed)
		Effect.Type.MOVEMENT_BLOCK:
			_remove_effect_helper(effect, movement_blocks, movement_blocks_changed)
		Effect.Type.ROTATION_BLOCK:
			_remove_effect_helper(effect, rotation_blocks, rotation_blocks_changed)

func _apply_effect_helper(effect: Effect, array: Array[Effect], _signal: Signal):
	array.append(effect)
	_signal.emit()
	
	await get_tree().create_timer(effect.duration).timeout
	expired.emit(effect)

func _remove_effect_helper(effect: Effect, array: Array[Effect], _signal: Signal):
	print("tenativo di rimozione: ", array.has(effect))
	if array.has(effect):
		array.erase(effect)
		_signal.emit()
