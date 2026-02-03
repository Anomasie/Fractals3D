@tool
extends MultiMeshInstance3D

signal drew_points

#@export var PMesh : Mesh
#@export var radius := 0.005

func maxis_ifs():
	
	var math = Math.new()
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
	
	return [con1, con2, con3]

func _ready():
	var my_ifs = IFS.random_ifs()
	my_ifs.systems = maxis_ifs()
	draw_points(my_ifs.calculate_fractal(point.new(), 500000))
	await Engine.get_main_loop().process_frame
	drew_points.emit(self.get_aabb().size)

func draw_points(points):
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors=true
	var pmesh = PointMesh.new()
#	var material := StandardMaterial3D.new()
#	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
#	material.albedo_color=Color(1,1,1)
#	material.point_size=1
#	material.vertex_color_use_as_albedo=true
#	pmesh.material=material    
	pmesh.material = load("res://scenes/Shadow.tres")
	
	multimesh.mesh=pmesh
	multimesh.instance_count = len(points)
	
	var i = 0
	for p in points:
		var pos = p.position
		i += 1
		multimesh.set_instance_color(i,Color.WHITE)#Color.BLACK+pos.y*Color.WHITE)
		multimesh.set_instance_transform(i, Transform3D(Basis(), pos))
	
	#self.multimesh = pmesh
