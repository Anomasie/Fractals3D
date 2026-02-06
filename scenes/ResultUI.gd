extends Control

signal drew_points

var current_ifs

# how many points should be drawn (in this frame and at all?)
var limit = 0
var frame_limit = 1000 # to manage frame performance
var max_frame_limit = 100000
var frame_step = 100
var counter = 0

@onready var Result3D = $ViewportContainer/Subviewport/Result3D

@onready var PointSlider = $Screen/Columns/Left/Bottom/Grid/PointSlider
@onready var PointTeller = $Screen/Columns/Left/Bottom/Grid/PointSlider/PointTeller
@onready var PointLineEdit = $Screen/Columns/Left/Bottom/Grid/PointLineEdit

func maxis_ifs():

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
	con1.matrix = Math.multiply(2.0/3, R)
	con1.translation = t
	var con2 = Contraction.new()
	con2.matrix = Math.multiply(2.0/3, Math.multiply(R2, R))
	con2.translation = Math.multiply(R2, t)
	var con3 = Contraction.new()
	con3.matrix = Math.multiply(2.0/3, Math.multiply(R3, R))
	con3.translation = Math.multiply(R3, t)

	print("1: ", con1.matrix)
	print("2: ", con2.matrix)
	print("3: ", con3.matrix)

	return [con1, con2, con3]

func _ready():
	# set values
	## PointTeller (ActualValueSlider)
	PointSlider.value = point_slider_descaled(Global.DEFAULT_POINTS)
	limit = Global.DEFAULT_POINTS
	PointTeller.min_value = PointSlider.min_value
	PointTeller.max_value = PointSlider.max_value
	PointTeller.value = 0
	PointLineEdit.placeholder_text = str(limit)
	
	# new ifs
	current_ifs = IFS.random_ifs()
	current_ifs.systems = maxis_ifs()

func _process(delta):
	draw_points(delta)

func draw_points(delta):
	if limit < 0 or counter < limit:
		# decide how many points to be calculated in one frame
		if len(current_ifs.systems) > 0:
			if delta > 1.0/15: # too slow
				frame_limit = max(0, frame_limit-frame_step)
			if delta < 1.0/30: # fast enough
				frame_limit = min(frame_limit+frame_step, max_frame_limit)

		# calculate more points
		## how many?
		var amount = frame_limit
		if limit >= 0:
			amount = min(frame_limit, limit-counter)
		
		if counter <= 0:
			Result3D.restart_mesh(limit, current_ifs.calculate_fractal(point.new(), amount))
		else:
			Result3D.add_points(current_ifs.calculate_fractal(point.new(), amount))
		counter += amount
		
		PointTeller.value = point_slider_descaled(counter)

# point limit

const POINT_LIMIT_HALF_VALUE = 1000000

func point_slider_scaled(x = float( PointSlider.value )):
	if x >= PointSlider.max_value:
		return -1
	else:
		return int(
			- log(float(PointSlider.max_value - x)/PointSlider.max_value) * POINT_LIMIT_HALF_VALUE
		)

func point_slider_descaled(y):
	if y < 0:
		return PointSlider.max_value
	else:
		return int( PointSlider.max_value * (1 - exp( - float(y) / POINT_LIMIT_HALF_VALUE )) ) + 1


func _on_point_slider_drag_ended(value_changed: bool) -> void:
	# set new point limit
	limit = point_slider_scaled()
	PointLineEdit.placeholder_text = str(limit)
	# if too many points:
	counter = 0
