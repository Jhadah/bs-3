extends Node

const PORT = 7777
var ip_address = "127.0.0.1"

func host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("server created")

func join_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, PORT)
	multiplayer.multiplayer_peer = peer
	print(peer , " joined")
