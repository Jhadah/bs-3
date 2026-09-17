extends PlayableCharacter

@onready var main_spell_base_hb = $Hitboxes/MainSpellBase
@onready var main_spell_emp_hb = $Hitboxes/MainSpellEmp
@onready var main_spell_recast_timer: Timer = $MainSpellRecastWindow

@export var main_spell_cast_time: float = 0
var current_cast: int = 0


@export var speed_buff: float
@export var speed_duration: float

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
	
	var mouse_pos = MouseManager.get_cursor_position_3d()                       #ROTAZIONE MOUSE
	if mouse_pos:
		look_at(Vector3(mouse_pos.x, global_position.y, mouse_pos.z))
	
	await get_tree().create_timer(main_spell_cast_time).timeout
	
	custom_rotation = false
	
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
		
		if current_cast == 0:
			print("primo cast")
			current_cast += 1
			
			var vfx: SpriteBase3D = instantiate_vfx("main_spell", "MainSpellBase")
			vfx.global_rotation_degrees -= Vector3(-45,0,0)
			damage_area(main_spell_base_hb, caster_stats.attack_damage)
			
			main_spell_recast_timer.start()
			recast_window_started_signal.emit("main", main_spell_recast_timer.wait_time)
			return
		
		if !main_spell_recast_timer.is_stopped():
			if current_cast == 1:
				current_cast += 1
				print("secondo cast")
				
				var vfx: SpriteBase3D = instantiate_vfx("main_spell", "MainSpellBase")
				vfx.global_rotation_degrees -= Vector3(45,0,0)
				damage_area(main_spell_base_hb, caster_stats.attack_damage)
				
				main_spell_recast_timer.start()
				recast_window_started_signal.emit("main", main_spell_recast_timer.wait_time)
			elif current_cast == 2:
				print("terzo cast, critico")
				
				instantiate_vfx("main_spell", "MainSpellBase")
				damage_area(main_spell_emp_hb, caster_stats.attack_damage * 2)
				
				current_cast = 0
				main_spell_recast_timer.stop()
				main_spell_recast_timer.timeout.emit()

@rpc("any_peer","call_local", "reliable")
func cast_secondary_spell():
	if is_secondary_spell_on_cooldown: return
	
	speed_buff_percentage += speed_buff                                         #SELF EFFECTS APPLIED
	spell_cooldown_start("secondary")                                           #COOLDOWN
	await get_tree().create_timer(speed_duration).timeout
	speed_buff_percentage -= speed_buff                                         #SELF EFFECTS REMOVED
	

func _on_main_attack_recast_window_timeout() -> void:
	spell_cooldown_start("main")
	recasts_endend_signal.emit("main")
	current_cast = 0
