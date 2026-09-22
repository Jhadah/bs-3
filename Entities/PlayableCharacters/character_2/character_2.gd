extends PlayableCharacter

@onready var main_spell_base_hb = $Hitboxes/MainSpellBase
@onready var main_spell_emp_hb = $Hitboxes/MainSpellEmp
@onready var main_spell_recast_timer: Timer = $MainSpellRecastWindow

@export var main_spell_cast_time: float = 0
var current_cast: int = 0

@export var main_spell_self_slow: float
@export var secondary_spell_speed_buff: float
@export var secondary_spell_speed_duration: float

func _ready() -> void:
	super._ready()
	
	character_id = 1
	
	vfx_library = {
		"main_spell": preload("uid://c8ub5ivyn07vp"),
	}

@rpc("any_peer","call_local", "reliable")
func cast_main_spell():
	if is_main_spell_on_cooldown: return
	
	custom_rotation = true
	movement.slow_factor += main_spell_self_slow                                #SELF EFFECTS APPLIED
	
	var mouse_pos = MouseManager.get_cursor_position_3d()                       #ROTAZIONE MOUSE
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	#--- ⌄ server side ⌄ ---#
	if multiplayer.is_server():
		var caster = get_player_from_sender_id(multiplayer.get_remote_sender_id())
		
		if current_cast == 0:
			print("primo cast")
			execute_main_spell_cast(caster, -45)
			return
		
		if !main_spell_recast_timer.is_stopped():
			if current_cast == 1:
				print("secondo cast")
				execute_main_spell_cast(caster, 45)
			elif current_cast == 2:
				print("terzo cast")
				execute_main_spell_cast(caster, 0, true)
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	custom_rotation = false                                                     #SELF EFFECTS REMOVED
	movement.slow_factor -= main_spell_self_slow

func execute_main_spell_cast(caster:PlayableCharacter, sprite_rotation: float, is_emp: bool = false):
	var vfx: SpriteBase3D = instantiate_vfx("main_spell", "Hitboxes/MainSpellBase")
	
	if !is_emp:
		damage_area(main_spell_base_hb, caster.attack.attack_damage)
		current_cast += 1
		vfx.global_rotation_degrees -= Vector3(sprite_rotation,0,0)
		main_spell_recast_timer.start()
		recast_window_started_signal.emit("main", main_spell_recast_timer.wait_time)
	else:
		damage_area(main_spell_emp_hb, caster.attack.attack_damage * 2)
		current_cast = 0
		main_spell_recast_timer.stop()
		main_spell_recast_timer.timeout.emit()

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	
	movement.buff_factor += secondary_spell_speed_buff                          #SELF EFFECTS APPLIED
	spell_cooldown_start("secondary")                                           #COOLDOWN
	await get_tree().create_timer(secondary_spell_speed_duration).timeout
	movement.buff_factor -= secondary_spell_speed_buff                          #SELF EFFECTS REMOVED

func _on_main_attack_recast_window_timeout() -> void:
	spell_cooldown_start("main")
	recasts_endend_signal.emit("main")
	current_cast = 0
