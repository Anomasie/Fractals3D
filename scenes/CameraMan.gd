#tool
extends Marker3D

@onready var CamPositioner = $CamPositioner

var rotating_camera = false
var rotating_origin = Vector2i.ZERO # position on screen when rotating_camera was activated

func _input(event):
	if event.is_action_pressed("scroll_out") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 1.1
	elif event.is_action_pressed("scroll_in") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 0.9
	elif event.is_action_pressed("activate_camera_rotating"):
		rotating_camera = true
		rotating_origin = event.position
	elif event.is_action_released("activate_camera_rotating"):
		rotating_camera = false

func _process(_delta):
	if rotating_camera:
		if self.rotation.x > PI/2 or self.rotation.x < -PI/2:
			self.rotation.y -= ((rotating_origin - get_viewport().get_mouse_position()).x / 360)
		else:
			self.rotation.y += ((rotating_origin - get_viewport().get_mouse_position()).x / 360)
		self.rotation.x += ((rotating_origin - get_viewport().get_mouse_position()).y / 360)
		if self.rotation.x < -PI: self.rotation.x += 2*PI
		if self.rotation.x > PI: self.rotation.x -= 2*PI
		rotating_origin = get_viewport().get_mouse_position()
