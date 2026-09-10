extends PlayableCharacter

@onready var main_attack_hb = $Hitboxes/MainAttackHB

@onready var main_attack_vfx = preload("uid://cfjxj4e4ojsgx")

var main_attack_cast_time: float = 1.0
var main_attack_self_slow: float = 80

func request_main_attack():
	var mouse_pos = MouseManager.get_cursor_position_3d()
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	super.request_main_attack()

@rpc("any_peer","call_local", "reliable") #call local solo se l'host è un giocatore
func cast_main_attack(attacker_peer_id: int):
	
	#region estetica
	
	var vfx: Vfx = main_attack_vfx.instantiate()
	add_child(vfx)
	
	#endregion
		
	if multiplayer.is_server():
		
		#region soggetti dell'azione
		
		var attacker: Entity = get_peer_node_from_peer_id(attacker_peer_id)
		var targets: Array = main_attack_hb.get_overlapping_bodies()
		
		#endregion
		
		
		
		#region funzionalità dell'abilità
		
		
		
		for target in targets:
			if target.has_method("take_damage") and target != self:
				target.take_damage.rpc(attacker.stats.attack_damage)
				
		slow_percentage += main_attack_self_slow
		await get_tree().create_timer(main_attack_cast_time).timeout
		slow_percentage -= main_attack_self_slow
		#endregion
