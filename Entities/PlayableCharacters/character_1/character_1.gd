extends PlayableCharacter

# Componenti
@onready var main_spell_hb = $Hitboxes/MainSpell

# Configurazione e Bilanciamento
@export var main_spell_cast_time: float
@export var main_spell_self_slow: float
@export var secondary_spell_self_root_duration: float
@export var secondary_spell_mana_cost: float

# --- Ciclo di Vita ---

func _ready() -> void:
	super._ready()
	character_id = 0
	
# --- Sistema di Spell e Abilità ---
	
@rpc("any_peer","call_local", "reliable")
func cast_main_spell():
	if is_main_spell_on_cooldown: return
	
	# SELF EFFECTS APPLIED
	apply_effect(Effect.Type.SPEED_DEBUFF,main_spell_cast_time,main_spell_self_slow, Effect.Calculation.PERCENTAGE)#self slow
	apply_effect(Effect.Type.ROTATION_BLOCK, main_spell_cast_time)#rotation block
	
	# ROTAZIONE MOUSE
	var mouse_pos = MouseManager.get_cursor_position_3d()
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	# COOLDOWN
	spell_cooldown_start.rpc("main")
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var caster = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		var damage_dealt = caster.attack.attack_damage # DAMAGE
		damage_area(main_spell_hb, damage_dealt)

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	if !mana.can_spend(secondary_spell_mana_cost): return
	
	var movement_block = Effect.new(Effect.Type.MOVEMENT_BLOCK, secondary_spell_self_root_duration)
	effect.apply_effect(movement_block)
	
	# COOLDOWN
	spell_cooldown_start.rpc("secondary")
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var caster: PlayableCharacter = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		if caster.mana.can_spend(secondary_spell_mana_cost):
			mana.spend_mana(secondary_spell_mana_cost)
		
		caster.health.heal.rpc(caster.health.max_health * 0.1)
