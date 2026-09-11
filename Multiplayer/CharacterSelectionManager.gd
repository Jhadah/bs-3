extends Node

var selection: Dictionary = {}

@rpc("any_peer", "call_local","reliable")
func request_select_character(character_id):
	if multiplayer.is_server():  #safety net, è ridondante ma lo tengo perchè mi conosco zio pera
		var sender_id = multiplayer.get_remote_sender_id()
		if sender_id == 0:
			sender_id = multiplayer.get_unique_id()
		selection[sender_id] = character_id
	
		spawn_player(sender_id, character_id)

func spawn_player(peer_id: int, character_id: int):
	var scene: PackedScene = Roster.characters[character_id].scene
	var instance = scene.instantiate() as Node3D
	instance.name = str(peer_id)
	
	var players_container = get_tree().get_first_node_in_group("players_container")
	players_container.add_child(instance)
	
	EntityRegistry.register(instance, peer_id)
