extends PlayableCharacter

# Componenti
@onready var main_spell_base_hb = $Hitboxes/MainSpellBase
@onready var main_spell_emp_hb = $Hitboxes/MainSpellEmp
@onready var main_spell_recast_timer: Timer = $MainSpellRecastWindow

# Configurazione e Bilanciamento
@export var main_spell_cast_time: float
@export var main_spell_self_slow: float
@export var secondary_spell_speed_buff: float
@export var secondary_spell_speed_duration: float

# Stato Interno
var current_cast: int = 0

# --- Ciclo di Vita ---

func _ready() -> void:
	super._ready()
	character_id = 1

# --- Sistema di Spell e Abilità ---

@rpc("any_peer","call_local", "reliable")
func cast_main_spell():
	if is_main_spell_on_cooldown: return
	
	# SELF EFFECTS APPLIED
	movement.custom_rotation = true
	movement.slow_factor += main_spell_self_slow
	
	# ROTAZIONE MOUSE
	var mouse_pos = MouseManager.get_cursor_position_3d()
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var caster = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		
		if current_cast == 0:
			print("primo cast")
			execute_main_spell_cast(caster)
		elif !main_spell_recast_timer.is_stopped():
			if current_cast == 1:
				print("secondo cast")
				execute_main_spell_cast(caster)
			elif current_cast == 2:
				print("terzo cast")
				execute_main_spell_cast(caster, true)
	
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	# SELF EFFECTS REMOVED
	movement.custom_rotation = false
	movement.slow_factor -= main_spell_self_slow

func execute_main_spell_cast(caster: PlayableCharacter, is_emp: bool = false):
	if !is_emp:
		var damage = caster.attack.attack_damage
		damage_area(main_spell_base_hb, damage)
		current_cast += 1
		main_spell_recast_timer.start()
		recast_window_started_signal.emit("main", main_spell_recast_timer.wait_time)
	else:
		var damage = crit(caster.attack.attack_damage)
		damage_area(main_spell_emp_hb, damage)
		current_cast = 0
		main_spell_recast_timer.stop()
		main_spell_recast_timer.timeout.emit()

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	
	# SELF EFFECTS APPLIED
	movement.buff_factor += secondary_spell_speed_buff
	
	# COOLDOWN
	spell_cooldown_start("secondary")
	
	await get_tree().create_timer(secondary_spell_speed_duration).timeout
	
	# SELF EFFECTS REMOVED
	movement.buff_factor -= secondary_spell_speed_buff

# --- Segnali e Eventi ---

func _on_main_attack_recast_window_timeout() -> void:
	spell_cooldown_start("main")
	recasts_endend_signal.emit("main")
	current_cast = 0
