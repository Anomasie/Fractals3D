class_name Contraction

const PRINT_ERRORS = false

var translation = Vector3.ZERO
var matrix = Basis(
		Vector3(0.3, 0, 0),
		Vector3(0, 0.3, 0),
		Vector3(0, 0, 0.3)
	) * Basis.IDENTITY
var rotation = Vector3.ZERO
var scale = 0.3 * Vector3.ONE
var color = Color.WHITE

func _ready():
	print("in CONTRACTION: PRINT_ERRORS is ", PRINT_ERRORS)

func calculate_matrix() -> void:
	self.matrix = Basis(
		self.scale.x * Vector3(1,0,0),
		self.scale.y * Vector3(0,1,0),
		self.scale.z * Vector3(0,0,1)
	) * Basis.from_euler(-self.rotation)

static func random_contraction():
	var contraction = Contraction.new()
	contraction.translation = Vector3( Math.nrnumber()/2, Math.nrnumber()/2, Math.nrnumber()/2 )
	contraction.rotation = Vector3(randf(), randf(), randf())
	contraction.scale = Vector3(Math.nrnumber(), Math.nrnumber(), Math.nrnumber())
	contraction.calculate_matrix()
	if PRINT_ERRORS: print("in Contraction: TODO")
	contraction.color = Color.from_hsv(randf(), randf(), randf())
	return contraction

func mult_matrix_with_vector_3d(A, p):
	return Vector3(
		A[0][0] * p.x + A[0][1] * p.y + A[0][2] * p.z,
		A[1][0] * p.x + A[1][1] * p.y + A[1][2] * p.z,
		A[2][0] * p.x + A[2][1] * p.y + A[2][2] * p.z
	)

func apply(p):
	if p is Vector3:
		return mult_matrix_with_vector_3d(matrix, p) + translation
	if p is point:
		p.position = self.apply(p.position)
		p.color = self.mix(p.color)
		return p
	elif p is Contraction: # return self ° p
		return "?"
	elif p is Array:
		var systems = []
		for system in p:
			systems.append(self.apply(system))
		return systems

func apply_to_preserve_image(ifs):
	for i in len(ifs.systems):
		ifs.systems[i].translation = self.apply(ifs.systems[i].translation) - self.translation
	return ifs

func center_with_preserving_image():
	pass

func mix(c):
	c.r = linear(c.r, color.r)
	c.g = linear(c.g, color.g)
	c.b = linear(c.b, color.b)
	return c

func linear(a, b, lambda=0.5):
	return lambda * a + (1 - lambda) * b
