class_name Projectile
extends CharacterBody3D

enum Type {SKILLSHOT, HOMING}
@export var type: Type
@export var speed: float

var dir: Vector3  #if skillshot
var target: Node3D  #if homing

var max_distance: float  #if skillshot
var starting_position: Vector3
var distance_traveled: float = 0

func _ready() -> void:
	if type == Type.SKILLSHOT:
		starting_position = global_position

func _physics_process(_delta: float) -> void:
	if type == Type.HOMING:
		if !is_instance_valid(target): queue_free()
		dir = target.global_position - global_position
	
	velocity = dir.normalized() * speed
	
	move_and_slide()
	
	if type == Type.SKILLSHOT:
		distance_traveled = global_position.distance_to(starting_position)
		if distance_traveled >= max_distance:
			queue_free()
	
