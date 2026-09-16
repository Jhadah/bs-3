extends Control

@onready var parent: PlayableCharacter = get_parent()

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_bar_label: Label = $HealthBar/HealthBarLabel
@onready var main_spell_label: Label = $MainSpell/MainSpellCooldown
@onready var main_spell_icon: TextureRect = $MainSpell/MainSpellIcon
@onready var secondary_spell_label: Label = $SecondarySpell/SecondarySpellCooldown
@onready var secondary_spell_icon: TextureRect = $SecondarySpell/SecondarySpellIcon

func _ready() -> void:
	if !is_multiplayer_authority():
		visible = false
	parent.health_updated.connect(_on_health_updated)
	parent.spell_cooldown_started_signal.connect(_on_spell_cooldown_started)
	
	await get_tree().process_frame
	
	var roster = get_node("/root/Roster")
	main_spell_icon.texture = roster.characters[parent.character_id]["main_spell_icon"]
	secondary_spell_icon.texture = roster.characters[parent.character_id]["secondary_spell_icon"]
	
	_on_health_updated(parent.current_health)

func _on_health_updated(new_amount: float):
	health_bar.value = new_amount
	health_bar_label.text = str((new_amount), "/", parent.stats.max_health)

func _on_spell_cooldown_started(spell: String):
	var label: Label
	var icon: TextureRect
	var time: float
	match spell:
		"main":
			main_spell_label.visible = true
			label = main_spell_label
			icon = main_spell_icon
			time = parent.cooldowns.main_spell_cooldown
		"secondary":
			secondary_spell_label.visible = true
			label = secondary_spell_label
			icon = secondary_spell_icon
			time = parent.cooldowns.secondary_spell_cooldown
	
	
	var tween: Tween = create_tween()
	tween.tween_method(update_icon_in_cooldown.bind(label, icon), time, 0.0, time)

func update_icon_in_cooldown(value: float, label: Label, icon: TextureRect):
	label.text = str(snappedf(value, 0.1))
	icon.self_modulate = Color(0.1,0.1,0.1)

	if label.text == "0.0":
		label.visible = false
		icon.self_modulate = Color(1,1,1)
	
