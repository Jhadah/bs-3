class_name PlayableCharacter 
extends Entity

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		handle_movement()

func handle_movement():
	var input = Input.get_vector("a", "d", "w", "s")
	var dir = Vector3(input.x, 0, input.y)
	
	var final_speed = stats.speed * (1.0 - clamp(slow_percentage, 0, 100) / 100)
	velocity = dir * final_speed
	move_and_slide()
