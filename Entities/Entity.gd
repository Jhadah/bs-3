class_name Entity
extends CharacterBody3D

var entity_id: int

var vfx_library: Dictionary = {}

var dir: Vector3

@onready var movement: MovementComponent = $MovementComponent
@onready var health: HealthComponent = $HealthComponent
@onready var attack: AttackComponent = $AttackComponent

@rpc("any_peer","call_local","reliable")
func instantiate_vfx(vfx: String, anchor: String):
	var vfx_scene: Vfx = vfx_library[vfx].instantiate()
	var parent = get_node(anchor)
	parent.add_child(vfx_scene)
	return vfx_scene

func die():
	if self is PlayableCharacter:
		visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	else:  #per minion etc
		queue_free()
