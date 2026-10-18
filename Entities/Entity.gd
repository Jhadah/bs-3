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
	if self is PlayableCharacter:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:  #per minion etc
		queue_free()

func _on_effect_expired(e: Effect):
	effect.remove_effect(e)
