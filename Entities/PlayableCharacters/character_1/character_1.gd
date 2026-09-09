extends PlayableCharacter

@onready var main_attack_hb = $Hitboxes/MainAttackHB

func request_main_attack():
	var mouse_pos = MouseManager.get_cursor_position_3d()
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	super.request_main_attack()

@rpc("any_peer","call_local", "reliable") #call local solo se l'host è un giocatore
func cast_main_attack(attacker_peer_id: int):
	if multiplayer.is_server():
		var attacker: Entity = get_peer_node_from_peer_id(attacker_peer_id)
		var targets: Array = main_attack_hb.get_overlapping_bodies()
		
		for target in targets:
			if target.has_method("take_damage") and target != self:
				target.take_damage.rpc(attacker.stats.attack_damage)
