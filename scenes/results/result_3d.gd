extends Node3D

@onready var ResultMesh = $ResultMesh

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
