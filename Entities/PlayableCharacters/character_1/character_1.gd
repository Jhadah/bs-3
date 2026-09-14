extends PlayableCharacter

@onready var main_attack_hb = $Hitboxes/MainAttack


var main_attack_cast_time: float = 1
var main_attack_self_slow: float = 40

func _ready() -> void:
	super._ready()
	
	vfx_library = {
		"main_attack": preload("uid://cfjxj4e4ojsgx"),
	}

func request_main_attack():
	var mouse_pos = MouseManager.get_cursor_position_3d()
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
		$Hitboxes/MainAttack.look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	super.request_main_attack() # semplicemente l'invio rpc

@rpc("any_peer","call_local", "reliable")
func cast_main_attack():
	
	custom_rotation = true
	slow_percentage += main_attack_self_slow
	await get_tree().create_timer(main_attack_cast_time).timeout
	instantiate_vfx.rpc("main_attack", "MainAttack")
	var vfx_anchor = $Hitboxes/MainAttack
	if vfx_anchor.get_child_count() > 0:
		var vfx_instance: Vfx = vfx_anchor.get_child(vfx_anchor.get_child_count() - 1)
		if vfx_instance:
			await  vfx_instance.animation_finished
	
	slow_percentage -= main_attack_self_slow
	custom_rotation = false
	
	if multiplayer.is_server():
		
		#region soggetti dell'azione
		
		var sender_id = multiplayer.get_remote_sender_id()
		
		var attacker_id = EntityRegistry.get_entity_id_for_peer_id(sender_id)
		var attacker: Entity
		if sender_id == 0:
			attacker = self
		else:
			attacker = EntityRegistry.get_entity(attacker_id)
		var attacker_stats: EntityStats = attacker.stats
		
		var targets: Array = main_attack_hb.get_overlapping_bodies()
		
		#endregion
		
		#region funzionalità dell'abilità
		
		#slow_percentage += main_attack_self_slow
		#deliberate_rotation = true
		#await get_tree().create_timer(main_attack_cast_time).timeout
	#
		#instantiate_vfx.rpc("main_attack", "MainAttack")
		
		for target in targets:
			if target.has_method("take_damage") and target != self:
				target.take_damage.rpc(attacker_stats.attack_damage)
		
		#slow_percentage -= main_attack_self_slow
		#
		#deliberate_rotation = false
		
		#endregion
