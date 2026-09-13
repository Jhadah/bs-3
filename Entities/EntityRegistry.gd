extends Node

var registry: Dictionary = {}
var peer_to_entity: Dictionary = {}

var next_id: int = 1

func register(entity: Entity, peer_id: int):
	entity.entity_id = next_id
	next_id += 1      #questa riga mi puzza, da vedere in futuro se rompe 
	
	registry[entity.entity_id] = entity
		
	if peer_id != -1:
		peer_to_entity[peer_id] = entity.entity_id
		
		if "peer_id" in entity:
			entity.peer_id = peer_id

func get_entity(entity_id: int):
	return registry.get(entity_id)
									   #non ho capito
func get_entity_id_for_peer_id(peer_id: int):
	return peer_to_entity.get(peer_id, -1)
