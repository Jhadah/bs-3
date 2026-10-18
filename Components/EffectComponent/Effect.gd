class_name Effect
extends RefCounted


enum Type {SPEED_BUFF, SPEED_DEBUFF, MOVEMENT_BLOCK, ROTATION_BLOCK}
var type: Type

enum Calculation {FLAT, PERCENTAGE, IRRELEVANT}
var calculation: Calculation

var amount: float
var duration: float

func _init(_type: Type, _duration: float, _amount: float = 0, _calculation: Calculation = Calculation.IRRELEVANT) -> void:
	type = _type
	duration = _duration
	amount = _amount
	calculation = _calculation
