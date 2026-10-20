class_name Entity
extends CharacterBody3D

var entity_id: int

@onready var movement: MovementComponent = $MovementComponent
@onready var health: HealthComponent = $HealthComponent
@onready var attack: AttackComponent = $AttackComponent
@onready var effect: EffectComponent = $EffectComponent

var dir: Vector3

func _ready() -> void:
	effect.expired.connect(_on_effect_expired)

func die():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED

func _on_effect_expired(e: Effect):
	effect.remove_effect(e)

func apply_effect(type: Effect.Type, duration: float, amount: float = 0, calculation : Effect.Calculation = Effect.Calculation.NO):
		var _effect = Effect.new(type, duration, amount, calculation)
		effect.apply_effect(_effect)
