@tool
extends MultiMeshInstance3D

signal drew_points

@export var PMesh : Mesh
@export var radius := 0.005

func _ready():
	var math = Math.new()
	var my_ifs = IFS.random_ifs()
	
	var R = [
		[0,0,-1],
		[0,1,0],
		[1,0,0]
	]
	var R2 = [
		[-0.5, -sqrt(3)/2, 0],
		[sqrt(3)/2, -0.5, 0],
		[0,0,1]
	]
	var R3 = [
		[-0.5, sqrt(3)/2, 0],
		[-sqrt(3)/2, -0.5, 0],
		[0,0,1]
	]
	var t = Vector3(0, sqrt(3)/3, 0)
	
	var con1 = Contraction.new()
	print("START!")
	con1.matrix = math.multiply(2.0/3, R)
	con1.translation = t
	var con2 = Contraction.new()
	con2.matrix = math.multiply(2.0/3, math.multiply(R2, R))
	con2.translation = math.multiply(R2, t)
	var con3 = Contraction.new()
	con3.matrix = math.multiply(2.0/3, math.multiply(R3, R))
	con3.translation = math.multiply(R3, t)
	
	print("1: ", con1.matrix)
	print("2: ", con2.matrix)
	print("3: ", con3.matrix)
	
	my_ifs.systems = [con1, con2, con3]
	draw_points(my_ifs.calculate_fractal(point.new(), 3000))
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
