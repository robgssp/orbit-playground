extends Spatial

var ship_velocity = Vector3(0, 0, -2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("swap_camera"):
		if $Ship/ShipCamera.current:
			$TopDownCamera.make_current()
		else:
			$Ship/ShipCamera.make_current()

