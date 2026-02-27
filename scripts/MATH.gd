class_name Math

#const VECTOR_EPSILON = 0.00001

static func rotation_matrix(rotation : Vector3):
	return multiply( multiply(yaw_matrix(rotation.x), pitch_matrix(rotation.y)), roll_matrix(rotation.z) )

static func yaw_matrix(alpha):
	return [
		[cos(alpha), -sin(alpha), 0],
		[sin(alpha), cos(alpha), 0],
		[0, 0, 1]
	]

static func pitch_matrix(alpha):
	return [
		[cos(alpha), 0, sin(alpha)],
		[0, 1, 0],
		[-sin(alpha), 0, cos(alpha)]
	]

static func roll_matrix(alpha):
	return [
		[1, 0, 0],
		[0, cos(alpha), -sin(alpha)],
		[0, sin(alpha), cos(alpha)]
	]


static func maxis_ifs():

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
	con1.matrix = Math.multiply(2.0/3, R)
	con1.translation = t
	var con2 = Contraction.new()
	con2.matrix = Math.multiply(2.0/3, Math.multiply(R2, R))
	con2.translation = Math.multiply(R2, t)
	var con3 = Contraction.new()
	con3.matrix = Math.multiply(2.0/3, Math.multiply(R3, R))
	con3.translation = Math.multiply(R3, t)
	return [con1, con2, con3]

static func multiply(obj1, obj2):
	if typeof(obj1) == TYPE_FLOAT:
		return scalar_mult(obj1, obj2)
	elif typeof(obj1) == TYPE_ARRAY:
		if typeof(obj2) == TYPE_ARRAY:
			return matrix_mult(obj1, obj2)
		elif typeof(obj2) == TYPE_VECTOR3:
			return apply_matrix(obj1, obj2)

static func apply_matrix(A, x):
	var result = matrix_mult(A, [[x.x], [x.y], [x.z]])
	return Vector3(result[0][0], result[1][0], result[2][0])

static func matrix_mult(A, B):
	if len(A[0]) == len(B):
		var result = []
		for i in len(A):
			var row = []
			for j in len(B[0]):
				var sum = 0
				for k in len(A[0]):
					sum += A[i][k] * B[k][j]
				row.append(sum)
			result.append(row)
		return result
	print("ERROR in Math.matrix_mult: dimension error because trying to multiply ", A, " and ", B)

static func scalar_mult(alpha, x):
	if typeof(x) == TYPE_ARRAY:
		var result = []
		for something in x:
			result.append(multiply(alpha, something))
		return result
	return alpha * x

static func are_equal_approx(A, B):
	if typeof(A) != typeof(B):
		print("WARNING in Math.are_equal_approx: object ", A, " and object ", B, " do not have the same type (", typeof(A), " != ", typeof(B), ")")
	elif typeof(A) == TYPE_COLOR:
		var col1 = Vector3(A.r, A.g, A.b)
		var col2 = Vector3(B.r, B.g, B.b)
		return (col1 - col2).length() < 1.0 / 250
