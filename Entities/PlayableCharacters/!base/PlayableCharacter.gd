class_name PlayableCharacter 
extends Entity

signal spell_cooldown_started_signal(spell: String)
signal recast_window_started_signal(spell: String, duration)
signal recasts_endend_signal(spell: String)

var is_main_spell_on_cooldown: bool = false
var is_secondary_spell_on_cooldown: bool = false

@export var cooldowns: CharacterCooldowns

var peer_id: int = -1
var character_id: int = -1

@onready var camera = $Camera3D

var custom_rotation: bool = false

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready() -> void:
	super._ready()
	
	if is_multiplayer_authority():
		camera.make_current()

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		handle_movement(delta)

func handle_movement(delta: float):
	var input = Input.get_vector("a", "d", "w", "s")
	dir = Vector3(input.x, 0, input.y)
	
	var buff_factor: float = max(0.0, speed_buff_percentage) / 100
	var slow_factor: float = clamp(slow_percentage, 0, 100) / 100
	
	var final_speed = stats.speed * (1 + buff_factor - slow_factor)
	velocity = dir * final_speed
	
	if dir != Vector3.ZERO and !custom_rotation:
		var target_rot: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 7.0)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("L-click"):
			request_spell(cast_main_spell)
		if event.is_action_pressed("shift"):
			request_spell(cast_secondary_spell)

func damage_area(area: Area3D, amount: float):
	var targets: Array = area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("take_damage") and target != self:
			target.take_damage.rpc(amount)

func request_spell(spell_method: Callable):
	spell_method.rpc()

func cast_main_spell():
	pass
func cast_secondary_spell():
	pass

@rpc("any_peer","call_local","reliable")
func spell_cooldown_start(spell: String):
	match spell:
		"main":
			is_main_spell_on_cooldown = true
			spell_cooldown_started_signal.emit("main")
			await get_tree().create_timer(cooldowns.main_spell_cooldown).timeout
			is_main_spell_on_cooldown = false
		"secondary":
			is_secondary_spell_on_cooldown = true
			spell_cooldown_started_signal.emit("secondary")
			await get_tree().create_timer(cooldowns.secondary_spell_cooldown).timeout
			is_secondary_spell_on_cooldown = false
