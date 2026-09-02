extends Control


func _on_host_button_pressed() -> void:
	Networking.host_game()
	hide()


func _on_join_button_pressed() -> void:
	Networking.join_game()
	hide()
