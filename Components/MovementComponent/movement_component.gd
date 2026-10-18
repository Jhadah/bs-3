class_name MovementComponent
extends Node

@onready var parent: Entity = get_parent()
@export var base_speed: float
var current_speed: float


var can_move: bool = true
var custom_rotation: bool = false

func _ready() -> void:
	await parent.ready
	parent.effect.speed_changed.connect(_on_speed_changed)
	parent.effect.movement_blocks_changed.connect(_on_movement_blocks_changed)
	parent.effect.rotation_blocks_changed.connect(_on_rotation_blocks_changed)
	
	current_speed = base_speed

func _physics_process(delta: float) -> void:
	if !parent.is_multiplayer_authority(): return
	if !can_move: return
	
	var input = Input.get_vector("a", "d", "w", "s")
	
	parent.dir = Vector3(input.x, 0, input.y)
	parent.velocity = parent.dir * current_speed
	
	if parent.dir != Vector3.ZERO and custom_rotation == false:
		var target_rot: float = atan2(-parent.dir.x, -parent.dir.z)
		parent.rotation.y = lerp_angle(parent.rotation.y, target_rot, delta * 7.0)
	
	parent.move_and_slide()

func compute_speed() -> float:
	var flat_speed_mod: float = 0
	var percentage_speed_mod: float = 0
	
	for ef in parent.effect.speed_buffs:
		if ef.calculation == Effect.Calculation.FLAT:
			flat_speed_mod += ef.amount
		else:
			percentage_speed_mod += ef.amount
	
	for ef in parent.effect.speed_debuffs:
		if ef.calculation == Effect.Calculation.FLAT:
			flat_speed_mod -= ef.amount
		else:
			percentage_speed_mod -= ef.amount
	
	var actual_speed = clamp((base_speed + flat_speed_mod) *  (1 + percentage_speed_mod), 1, 20)

	return actual_speed

func _on_speed_changed():
	current_speed = compute_speed()

func _on_movement_blocks_changed():
	if !parent.effect.movement_blocks.is_empty():
		can_move = false
	else:
		can_move = true

func _on_rotation_blocks_changed():
	if !parent.effect.rotation_blocks.is_empty():
		custom_rotation = true
	else:
		custom_rotation = false
