extends Node3D

@onready var ResultMesh = $ResultMesh

func center_mesh():
	ResultMesh.position = -ResultMesh.get_aabb().size/2

func add_points(points):
	ResultMesh.add_points(points)

func draw_points(points):
	ResultMesh.draw_points(points)
