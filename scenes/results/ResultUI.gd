extends Control

signal store_to_url

var current_ifs

# how many points should be drawn (in this frame and at all?)
var limit = 0
var frame_limit = 1000 # to manage frame performance
var frame_limit_for_new_ifs = 1000 # if ifs is loaded new
var max_frame_limit = 100000
var frame_factor = 1.2
var counter = 0

var file_counter = 0

@onready var Result3D = $ViewportContainer/Subviewport/Result3D

@onready var PointSlider = $Screen/Columns/Left/Bottom/Grid/PointSlider
@onready var PointTeller = $Screen/Columns/Left/Bottom/Grid/PointSlider/PointTeller
@onready var PointLineEdit = $Screen/Columns/Left/Bottom/Grid/PointLineEdit

@onready var BGColorSliders = $BGColorSliders
@onready var LightColorSliders = $LightColorSliders

@onready var BGColorButton = $Screen/Columns/Right/Top/Main/BGColorButton
@onready var LightColorButton = $Screen/Columns/Right/Top/Main/LightColorButton

@onready var SaveFileDialog = $SaveFile

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
	
	# hide & show
	BGColorSliders.hide()
	LightColorSliders.hide()
	SaveFileDialog.hide()

func set_ifs(new_ifs):
	new_ifs_this_frame = true
	current_ifs = new_ifs
	counter = 0
	#Result3D.restart_mesh(limit, [])#current_ifs.calculate_fractal(point.new(), 0))

func get_ifs() -> IFS:
	var ifs = current_ifs
	
	# constants
	ifs.reusing_last_point = false
	ifs.centered_view = false
	
	# colors
	ifs.background_color = Result3D.get_background_color()
	var lights = Result3D.get_light_colors()
	ifs.axis_color_x = lights[0]
	ifs.axis_color_y = lights[1]
	ifs.axis_color_z = lights[2]
	
	# camera
	var camera_data = Result3D.get_camera()
	ifs.camera_rotation = camera_data[0]
	ifs.camera_position = camera_data[1]
	
	return ifs

func _process(delta):
	draw_points(delta, new_ifs_this_frame)
	new_ifs_this_frame = false

func draw_points(delta, load_new_ifs=false):
	if limit < 0 or counter < limit:
		# decide how many points to be calculated in one frame
		if len(current_ifs.systems) > 0:
			if load_new_ifs:
				if delta > 1.0/7:
					frame_limit_for_new_ifs = frame_limit_for_new_ifs/frame_factor
				elif delta < 1.0/30:
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

# color sliders

## background color

func _on_bg_color_button_pressed() -> void:
	if BGColorButton.button_pressed:
		BGColorSliders.open(Result3D.get_background_color(), "Background Color")
	else:
		BGColorSliders.close()

func _on_bg_color_sliders_finished() -> void:
	BGColorSliders.close()
	BGColorButton.button_pressed = false

func _on_bg_color_sliders_color_changed() -> void:
	Result3D.set_background_color(BGColorSliders.get_color())

func _on_bg_color_sliders_color_changed_vastly() -> void:
	print("background color changed vastly!")

## Light colors

func _on_light_color_button_pressed() -> void:
	if LightColorButton.button_pressed:
		LightColorSliders.open(Result3D.get_light_colors(), "Light Colors")
	else:
		LightColorSliders.hide()

func _on_light_color_sliders_color_changed() -> void:
	Result3D.set_light_colors( LightColorSliders.get_colors() )

func _on_light_color_sliders_color_changed_vastly() -> void:
	print("light color changed vastly!")

func _on_light_color_sliders_finished() -> void:
	LightColorSliders.hide()
	LightColorButton.button_pressed = false

# saving

func get_image() -> Image:
	var texture = (Result3D.get_viewport().get_texture())
	return texture.get_image()

func save(path):
	# save image
	if not path.ends_with(".png") and not path.ends_with(".PNG"):
		get_image().save_png(path + ".png")
	else:
		get_image().save_png(path)

func _on_save_button_pressed() -> void:
	store_to_url.emit()
	if OS.has_feature("web"):
		var filename = "fractal" + str(file_counter) + ".png"
		file_counter += 1
		var buf = get_image().save_png_to_buffer()
		JavaScriptBridge.download_buffer(buf, filename)
	else:
		SaveFileDialog.open()

func _on_save_file_path_selected(path) -> void:
	save(path)

func _on_share_button_pressed() -> void:
	store_to_url.emit()
