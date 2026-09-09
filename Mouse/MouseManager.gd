extends Node3D

func get_cursor_position_3d():
	var camera = get_viewport().get_camera_3d()
	
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var target = origin + camera.project_ray_normal(mouse_pos) * 1000    #lunghezza raggio
	
	var query = PhysicsRayQueryParameters3D.create(origin, target)
	var ray = get_world_3d().direct_space_state.intersect_ray(query)
	
	if not ray.is_empty():
		return ray.position
	else: return null
