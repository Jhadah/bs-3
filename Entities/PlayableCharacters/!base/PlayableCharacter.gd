class_name PlayableCharacter 
extends Entity

var peer_id: int = -1

@onready var camera = $Camera3D

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
	var dir = Vector3(input.x, 0, input.y)
	
	var final_speed = stats.speed * (1.0 - clamp(slow_percentage, 0, 100) / 100)
	velocity = dir * final_speed
	
	if dir != Vector3.ZERO:
		var target_rot: float = atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 10.0)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("L-click"):
			request_main_attack()

func request_main_attack():
	cast_main_attack.rpc_id(1)

@rpc("any_peer","call_local", "reliable") #call local solo se l'host è un giocatore
func cast_main_attack():
	pass
