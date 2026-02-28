class_name Math

static func are_equal_approx(A, B):
	if typeof(A) != typeof(B):
		print("WARNING in Math.are_equal_approx: object ", A, " and object ", B, " do not have the same type (", typeof(A), " != ", typeof(B), ")")
	elif typeof(A) == TYPE_COLOR:
		var col1 = Vector3(A.r, A.g, A.b)
		var col2 = Vector3(B.r, B.g, B.b)
		return (col1 - col2).length() < 1.0 / 250

static func nrnumber() -> float: # nice random number
	var nrn = randf() + randf()
	nrn /= 2
	nrn *= (int(randf() < 0.5)-0.5)*2
	return nrn
