extends Node3D

@onready var ResultMesh = $ResultMesh

@onready var World = $WorldEnvironment

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

func set_background_color(new_color) -> void:
	World.environment.background_color = new_color

func get_background_color() -> Color:
	return World.environment.background_color
