class_name MovementComponent
extends Node

@export var base_speed: float
var actual_speed: float
var slow_factor: float
var buff_factor: float

var can_move: bool = true
var custom_rotation: bool = false

func _physics_process(_delta: float) -> void:
	actual_speed = base_speed * (1 + buff_factor - slow_factor)
