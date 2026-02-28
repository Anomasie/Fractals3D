@tool
extends MultiMeshInstance3D

var next_instance_to_draw = 0

func _ready():
	multimesh = MultiMesh.new()
	var current_ifs = IFS.random_ifs()
	prepare_mesh(10000)
	add_points(current_ifs.calculate_fractal(point.new(), 10000-1))

func add_points(points):
	#multimesh.instance_count += len(points)
	
	for p in points:
		if next_instance_to_draw < multimesh.instance_count:
			multimesh.set_instance_transform(next_instance_to_draw, Transform3D(Basis(), p.position))
			multimesh.set_instance_color(next_instance_to_draw, p.color)
			next_instance_to_draw += 1
	multimesh.visible_instance_count = next_instance_to_draw-1

func prepare_mesh(instance_count):
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.instance_count = instance_count
	multimesh.visible_instance_count = 0
	next_instance_to_draw = 0
	multimesh.mesh = PointMesh.new()
	multimesh.mesh.material = load("res://materials/PointMaterial.tres")
