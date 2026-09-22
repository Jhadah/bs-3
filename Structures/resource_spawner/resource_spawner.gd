extends Structure

var resource_given: int = 10

func give_resources(subject: Entity):
	if multiplayer.is_server():
		subject.obtain_resources()
