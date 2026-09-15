extends Control

@onready var parent: PlayableCharacter = get_parent()

@onready var health_bar: ProgressBar = $HealthBar
@onready var main_attack_cooldown_label: Label = $MainAttackCooldown

func _ready() -> void:
	if !is_multiplayer_authority():
		visible = false
	parent.health_updated.connect(_on_health_updated)
	parent.main_attack_cooldown_started_signal.connect(_on_main_attack_cooldown_started)
	
	await get_tree().process_frame
	
	_on_health_updated(parent.current_health)

func _on_health_updated(new_amount: float):
	health_bar.value = new_amount

func _on_main_attack_cooldown_started():
	
	main_attack_cooldown_label.visible = true
	
	var time: float = parent.cooldowns.main_attack_cooldown
	var tween: Tween = create_tween()
	tween.tween_method(update_displayed_time, time, 0.0, time)

func update_displayed_time(value: float):
	main_attack_cooldown_label.text = str(snappedf(value, 0.1))

	if main_attack_cooldown_label.text == "0.0":
		main_attack_cooldown_label.visible = false
	
