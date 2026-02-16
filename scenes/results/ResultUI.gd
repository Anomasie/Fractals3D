extends Control

var current_ifs

# how many points should be drawn (in this frame and at all?)
var limit = 0
var frame_limit = 1000 # to manage frame performance
var frame_limit_for_new_ifs = 1000 # if ifs is loaded new
var max_frame_limit = 100000
var frame_factor = 1.2
var counter = 0

@onready var Result3D = $ViewportContainer/Subviewport/Result3D

@onready var PointSlider = $Screen/Columns/Left/Bottom/Grid/PointSlider
@onready var PointTeller = $Screen/Columns/Left/Bottom/Grid/PointSlider/PointTeller
@onready var PointLineEdit = $Screen/Columns/Left/Bottom/Grid/PointLineEdit

var new_ifs_this_frame = false

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
	var new_ifs = IFS.random_ifs()
	new_ifs.systems = Math.maxis_ifs()
	self.set_ifs(new_ifs)

func set_ifs(new_ifs):
	new_ifs_this_frame = true
	current_ifs = new_ifs
	counter = 0
	#Result3D.restart_mesh(limit, [])#current_ifs.calculate_fractal(point.new(), 0))

func _process(delta):
	draw_points(delta, new_ifs_this_frame)
	new_ifs_this_frame = false

func draw_points(delta, load_new_ifs=false):
	if limit < 0 or counter < limit:
		# decide how many points to be calculated in one frame
		if len(current_ifs.systems) > 0:
			if load_new_ifs:
				if delta > 1.0/5:
					print("too slow ", frame_limit_for_new_ifs)
					frame_limit_for_new_ifs = frame_limit_for_new_ifs/frame_factor
				elif delta < 1.0/30:
					print("too fast ", frame_limit_for_new_ifs)
					frame_limit_for_new_ifs = frame_limit_for_new_ifs*frame_factor
			else:
				if delta > 1.0/30: # too slow
					frame_limit = frame_limit/frame_factor
				elif delta < 1.0/40: # fast enough
					frame_limit = frame_limit*frame_factor

		# calculate more points
		## how many?
		var amount = 0
		if load_new_ifs:
			amount = min(frame_limit_for_new_ifs, limit-counter)
		else:
			amount = min(frame_limit, limit-counter)
		
		if counter <= 0:
			Result3D.restart_mesh(limit, current_ifs.calculate_fractal(point.new(), amount))
		elif amount > 0:
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


func _on_point_slider_drag_ended(_value_changed: bool) -> void:
	# set new point limit
	limit = point_slider_scaled()
	PointLineEdit.placeholder_text = str(limit)
	# if too many points:
	counter = 0
