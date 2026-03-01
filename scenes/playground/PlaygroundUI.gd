extends Control

signal fractal_changed
signal fractal_changed_vastly

@onready var Playground = $ViewportContainer/Subviewport/Playground
# UI
## buttons
@onready var RemoveButton = $Left/Main/RemoveButton
@onready var ColorButton = $Left/Main/ColorButton
@onready var RemoveAllButton = $Left/Main/RemoveAllButton
@onready var GeometricButton = $Left/Main/GeometricButton
## extra menüs
@onready var ColorSliders = $ColorSliders
@onready var PresetsButton = $Bottom/PresetsButton
@onready var Presets = $Presets
@onready var GeometricOptions = $GeometricOptions

func _ready():
	# hide and show
	ColorSliders.close()
	_on_geometric_options_close_me()
	_on_presets_button_pressed()
	focus()

func set_ifs(ifs = IFS.random_ifs()) -> void:
	Playground.set_ifs(ifs)
	ColorSliders.UniformColorButton.on = ifs.uniform_coloring
	await Engine.get_main_loop().process_frame
	fractal_changed.emit(get_ifs())
	fractal_changed_vastly.emit(get_ifs())
	RemoveAllButton.disabled = (len(Playground.FocusedBoxes) == 0)

func get_ifs(ifs = Playground.get_ifs()) -> IFS:
	ifs.uniform_coloring = ColorSliders.UniformColorButton.on
	
	return ifs

func focus(boxes = []) -> void:
	Playground.focus(boxes)
	
	ColorButton.disabled = len(boxes) == 0
	RemoveButton.disabled = len(boxes) == 0
	RemoveAllButton.disabled = len(Playground.get_boxes()) == 0
	GeometricButton.disabled = len(boxes) == 0
	
	if GeometricOptions.visible:
		if len(Playground.get_boxes()) > 0:
			GeometricOptions.load_ui(Playground.get_contraction())
		else:
			_on_geometric_options_close_me()
	
	if len(boxes) > 0:
		if ColorButton.button_pressed:
			ColorSliders.open( boxes[0].get_color(), "" )
	else:
		# close everything
		ColorSliders.close()

# playground

func _on_playground_fractal_changed(ifs) -> void:
	fractal_changed.emit( self.get_ifs(ifs) )
	if GeometricOptions.visible:
		GeometricOptions.load_ui(Playground.get_contraction())

func _on_playground_focus_these(boxes) -> void:
	focus(boxes)

# buttons

func _on_color_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if len(Playground.FocusedBoxes) > 0:
			ColorSliders.open( Playground.FocusedBoxes[0].get_color(), "" )
	else:
		ColorSliders.close()

# color sliders

func _on_color_sliders_finished() -> void:
	ColorButton.button_pressed = false
	ColorSliders.close()

func _on_color_sliders_color_changed() -> void:
	Playground.set_color( ColorSliders.get_color() )
	
	fractal_changed.emit( self.get_ifs() )

## add and remove buttons

func _on_add_button_pressed() -> void:
	Playground.add_box()
	RemoveAllButton.disabled = (len(Playground.FocusedBoxes) == 0)
	if Presets.visible:
		_on_presets_close_me()
	
	fractal_changed.emit( self.get_ifs() )

func _on_duplicate_button_pressed() -> void:
	var current_contraction = Playground.get_contraction()
	current_contraction.translation += Vector3(0.1,0.1,0.1)
	Playground.add_box(current_contraction)
	RemoveAllButton.disabled = (len(Playground.FocusedBoxes) == 0)
	if Presets.visible:
		_on_presets_close_me()
	
	fractal_changed.emit( self.get_ifs() )

func _on_remove_button_pressed() -> void:
	# close rect
	await Playground.remove_current_boxes()
	focus([])
	
	fractal_changed_vastly.emit( self.get_ifs() )

func _on_remove_all_button_pressed() -> void:
	Playground.FocusedBoxes = Playground.get_boxes()
	_on_remove_button_pressed()

# presets

func _on_presets_close_me() -> void:
	PresetsButton.show()
	Presets.hide()

func _on_presets_load_preset(new_ifs) -> void:
	set_ifs(new_ifs)
	_on_presets_close_me()

func _on_presets_button_pressed() -> void:
	PresetsButton.hide()
	Presets.show()

# geometric options

func _on_geometric_button_pressed() -> void:
	if GeometricButton.button_pressed:
		GeometricOptions.open(Playground.get_contraction())
	else:
		_on_geometric_options_close_me()

func _on_geometric_options_changed() -> void:
	Playground.set_contraction( GeometricOptions.read_ui(), false )

func _on_geometric_options_close_me() -> void:
	GeometricOptions.hide()
	GeometricButton.button_pressed = false
	GeometricButton.disabled = len(Playground.FocusedBoxes)==0
