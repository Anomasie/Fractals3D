extends Node3D

@onready var ResultMesh = $ResultMesh
@onready var Lights = $Lights
@onready var World = $WorldEnvironment
@onready var CameraMan = $CameraManR

# Mesh functions

func center_mesh():
	pass
	#ResultMesh.position = ResultMesh.get_aabb().size/2

func add_points(points):
	ResultMesh.add_points(points)

func restart_mesh(limit, points=[]):
	ResultMesh.prepare_mesh(limit)
	ResultMesh.add_points(points)
	center_mesh()

# colors

## background

func set_background_color(new_color) -> void:
	World.environment.background_color = new_color

func get_background_color() -> Color:
	return World.environment.background_color

## axes

func set_light_colors(colors) -> void:
	Lights.set_light_colors(colors)

func get_light_colors() -> Array:
	return Lights.get_light_colors()

# camera

func get_camera() -> Array:
	return CameraMan.get_data()
