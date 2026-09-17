extends PlayableCharacter

@onready var main_spell_hb = $Hitboxes/MainSpell

@export var main_spell_cast_time: float = 0
@export var main_spell_self_slow: float = 0

func _ready() -> void:
	super._ready()
	
	character_id = 0
	
	vfx_library = {
		"main_spell": preload("uid://cfjxj4e4ojsgx"),
	}

@rpc("any_peer","call_local", "reliable")
func cast_main_spell():
	
	if is_main_spell_on_cooldown: return
	
	custom_rotation = true                                                      #SELF EFFECTS APPLIED
	slow_percentage += main_spell_self_slow
	
	var mouse_pos = MouseManager.get_cursor_position_3d()                       #ROTAZIONE MOUSE
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
		main_spell_hb.look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	spell_cooldown_start.rpc("main")                                            #COOLDOWN
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	instantiate_vfx.rpc("main_spell", "MainSpell")                              #VFX
	var vfx_anchor = main_spell_hb
	if vfx_anchor.get_child_count() > 0:
		var vfx_instance: Vfx = vfx_anchor.get_child(vfx_anchor.get_child_count() - 1)
		if vfx_instance:
			await  vfx_instance.animation_finished
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()                      #CASTER
		var caster: PlayableCharacter
		var caster_id = EntityRegistry.get_entity_id_for_peer_id(sender_id)
		if sender_id == 0:
			caster = self
		else:
			caster = EntityRegistry.get_entity(caster_id)
		var caster_stats: EntityStats = caster.stats
		
		var targets: Array = main_spell_hb.get_overlapping_bodies()             #TARGETING
		for target in targets:
			if target.has_method("take_damage") and target != self:
				target.take_damage.rpc(caster_stats.attack_damage)
	
	slow_percentage -= main_spell_self_slow                                     #SELF EFFECTS REMOVED
	custom_rotation = false

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	
	spell_cooldown_start.rpc("secondary")                                       #COOLDOWN
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()                      #CASTER
		var caster: PlayableCharacter
		var caster_id = EntityRegistry.get_entity_id_for_peer_id(sender_id)
		if sender_id == 0:
			caster = self
		else:
			caster = EntityRegistry.get_entity(caster_id)
		var caster_stats: EntityStats = caster.stats
		
		caster.heal.rpc(caster_stats.max_health * 0.1)
