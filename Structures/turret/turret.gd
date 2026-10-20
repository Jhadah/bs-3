extends Structure

@onready var attack_timer: Timer = $AttackTimer

var entities_in_range: Array[Entity]
var is_attacking: bool = false

@onready var turret_shot = preload("uid://cwyflev1myktq")

func _on_attack_range_body_entered(body: Node3D) -> void:
	if body is Entity:
		entities_in_range.append(body)
	
	await get_tree().create_timer(0.6).timeout
	if entities_in_range.has(body):
		_on_attack_timer_timeout()                     #problema di entra/esci che resetta il timer
		attack_timer.start()


func _on_attack_range_body_exited(body: Node3D) -> void:
	if entities_in_range.has(body):
		entities_in_range.erase(body)


func _on_attack_timer_timeout() -> void:
	var closest: Entity = null
	var closest_distance = INF
	if entities_in_range.is_empty(): return
	
	for entity in entities_in_range:
		var distance = global_position.distance_to(entity.global_position)
		if distance < closest_distance:
			closest = entity
			closest_distance = distance
	
	var projectile: Projectile = turret_shot.instantiate()
	projectile.global_position = global_position
	projectile.target = closest
	get_tree().root.add_child(projectile)
	print("sparato")
	
