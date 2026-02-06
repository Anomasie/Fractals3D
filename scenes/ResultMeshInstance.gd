extends MultiMeshInstance3D

var next_instance_to_draw = 0

func _ready():
	multimesh = MultiMesh.new()

func add_points(points):
	#multimesh.instance_count += len(points)
	
	for p in points:
		var pos = p.position
		multimesh.set_instance_color(next_instance_to_draw,Color.WHITE)
		multimesh.set_instance_transform(next_instance_to_draw, Transform3D(Basis(), pos))
		next_instance_to_draw += 1
	
	if multimesh.instance_count > 1050:
		print("in ResultMeshInstance: ", multimesh.instance_count, " & ", multimesh.get_instance_transform(1050).origin)

func prepare_mesh(instance_count):
	print("ResultMeshInstance: draw points!")
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors=true
	multimesh.instance_count = instance_count
	next_instance_to_draw = 0
	var pmesh = PointMesh.new()
	pmesh.material = load("res://scenes/Shadow.tres")
	
	multimesh.mesh=pmesh
