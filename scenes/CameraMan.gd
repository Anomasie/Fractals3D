extends Marker3D

var SPEED = 0.2

@onready var CamPositioner = $CamPositioner

func _process(delta):
	self.rotate_y(delta * SPEED)

func _input(event):
	if event.is_action_pressed("scroll_out") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 1.1
	elif event.is_action_pressed("scroll_in") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 0.9
