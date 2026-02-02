@tool
extends MultiMeshInstance3D

signal drew_points

@export var PMesh : Mesh
@export var radius := 0.005

func _ready():
	print("loaded!")
	var my_ifs = IFS.random_ifs()
	draw_points(my_ifs.calculate_fractal(point.new(), 10000))
	await Engine.get_main_loop().process_frame
	drew_points.emit(self.get_aabb().size)

func draw_points(points):
	var mesh = MultiMesh.new()

	mesh.transform_format = MultiMesh.TRANSFORM_3D
	mesh.instance_count = len(points)+1

	# Sphere mesh
	mesh.mesh = PMesh

	var i = 0
	for p in points:
		var pos = Vector3(
			p.position.x,
			p.position.z,
			p.position.y
		)
		i += 1
		var transf = Transform3D(Basis(), pos)
		mesh.set_instance_transform(i, transf)

	self.multimesh = mesh
