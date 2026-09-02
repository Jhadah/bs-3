extends Control

@onready var item_list = $ItemList

func _ready() -> void:
	for character in Roster.characters:
		item_list.add_item(character.name)

func _on_select_button_pressed() -> void:
	var selected_character_id = item_list.get_selected_items()[0]
	CharacterSelectionManager.request_select_character.rpc_id(1, selected_character_id)
	hide()
