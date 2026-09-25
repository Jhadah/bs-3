extends PlayableCharacter

@onready var main_spell_hb = $Hitboxes/MainSpell

@export var main_spell_cast_time: float
@export var main_spell_self_slow: float
@export var secondary_spell_self_root_duration: float

@export var secondary_spell_mana_cost: float

func _ready() -> void:
	super._ready()
	
	character_id = 0
	
	vfx_library = {
		"main_spell": preload("uid://cfjxj4e4ojsgx"),
	}

@rpc("any_peer","call_local", "reliable")
func cast_main_spell():
	
	if is_main_spell_on_cooldown: return
	
	movement.custom_rotation = true                                             #SELF EFFECTS APPLIED
	movement.slow_factor += main_spell_self_slow
	
	var mouse_pos = MouseManager.get_cursor_position_3d()                       #ROTAZIONE MOUSE
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
		main_spell_hb.look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	spell_cooldown_start.rpc("main")                                            #COOLDOWN
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	instantiate_vfx.rpc("main_spell", "Hitboxes/MainSpell")                     #VFX
	var vfx_anchor = main_spell_hb
	if vfx_anchor.get_child_count() > 0:
		var vfx_instance: Vfx = vfx_anchor.get_child(vfx_anchor.get_child_count() - 1)
		if vfx_instance:
			await  vfx_instance.animation_finished
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		
		var caster = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		
		var targets: Array = main_spell_hb.get_overlapping_bodies()             #TARGETING
		for target in targets:
			if target.has_method("take_damage") and target != self:
				target.take_damage.rpc(caster.attack.attack_damage)
		
	movement.slow_factor -= main_spell_self_slow                                #SELF EFFECTS REMOVED
	movement.custom_rotation = false

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	if !mana.can_spend(secondary_spell_mana_cost): return
	
	
	
	movement.can_move = false
	
	spell_cooldown_start.rpc("secondary")                                       #COOLDOWN
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		
		
		var caster: PlayableCharacter = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		
		if caster.mana.can_spend(secondary_spell_mana_cost):
			mana.spend_mana(secondary_spell_mana_cost)
		
		caster.health.heal.rpc(caster.health.max_health * 0.1)
	
	await get_tree().create_timer(secondary_spell_self_root_duration).timeout
	movement.can_move = true
