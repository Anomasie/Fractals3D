#tool
extends Marker3D

@onready var CamPositioner = $CamPositioner

var rotating_camera = false
var rotating_origin = Vector2i.ZERO # position on screen when rotating_camera was activated

var sync_camera : Node

func _ready():
	Global.Cams3D.append(self)

func _input(event):
	if event.is_action_pressed("scroll_out") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 21.0/20
		if sync_camera:
			sync_camera.load_data( self.rotation, CamPositioner.position )
	elif event.is_action_pressed("scroll_in") and CamPositioner.position.length() > 0:
		CamPositioner.position *= 20.0/21
		if sync_camera:
			sync_camera.load_data( self.rotation, CamPositioner.position )
	elif event.is_action_pressed("activate_camera_rotating"):
		if event.get("position"):
			rotating_origin = event.position
		elif not rotating_camera:
			rotating_origin = get_viewport().get_mouse_position()
		rotating_camera = true
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
		
		if sync_camera:
			sync_camera.load_data( self.rotation, CamPositioner.position )

func load_data(rot, pos):
	self.rotation = rot
	CamPositioner.position = pos

func sync_with(camera_man):
	sync_camera = camera_man
	if camera_man:
		self.rotation = camera_man.rotation
		self.CamPositioner.position = camera_man.CamPositioner.position
