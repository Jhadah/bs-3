class_name Entity
extends CharacterBody3D

var entity_id: int

@onready var movement: MovementComponent = $MovementComponent
@onready var health: HealthComponent = $HealthComponent
@onready var attack: AttackComponent = $AttackComponent

var dir: Vector3

func die():
	if self is PlayableCharacter:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:  #per minion etc
		queue_free()
