extends Node3D

@onready var ResultMesh = $ResultMesh

func _on_result_mesh_instance_drew_points(size) -> void:
	print(ResultMesh.name)
	#ResultMesh.position = size/2
