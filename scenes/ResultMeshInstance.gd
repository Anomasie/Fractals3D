extends MultiMeshInstance3D

func add_points(points):
	var i = multimesh.instance_count
	#multimesh.instance_count
	multimesh.instance_count += len(points)
	
	for p in points:
		var pos = p.position
		multimesh.set_instance_color(i,Color.WHITE)#Color.BLACK+pos.y*Color.WHITE)
		multimesh.set_instance_transform(i, Transform3D(Basis(), pos))
		i += 1

func draw_points(points):
	print("ResultMeshInstance: draw points!")
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors=true
	multimesh.instance_count = 0
	var pmesh = PointMesh.new()
	pmesh.material = load("res://scenes/Shadow.tres")
	
	multimesh.mesh=pmesh
	
	add_points(points)
