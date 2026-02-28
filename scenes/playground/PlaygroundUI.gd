extends Control

signal fractal_changed
signal fractal_changed_vastly

@onready var Playground = $ViewportContainer/Subviewport/Playground
# UI
## buttons
@onready var RemoveButton = $Left/Main/RemoveButton
@onready var ColorButton = $Left/Main/ColorButton
@onready var RemoveAllButton = $Left/Main/RemoveAllButton
## extra menüs
@onready var ColorSliders = $ColorSliders
@onready var PresetsButton = $Bottom/PresetsButton
@onready var Presets = $Presets

func _ready():
	# hide and show
	ColorSliders.close()
	_on_presets_button_pressed()
	focus()
	
	set_ifs(IFS.random_ifs())

func set_ifs(ifs = IFS.random_ifs()) -> void:
	Playground.set_ifs(ifs)
	ColorSliders.UniformColorButton.on = ifs.uniform_coloring
	await Engine.get_main_loop().process_frame
	fractal_changed.emit(get_ifs())
	fractal_changed_vastly.emit(get_ifs())

func get_ifs(ifs = Playground.get_ifs()) -> IFS:
	ifs.uniform_coloring = ColorSliders.UniformColorButton.on
	
	return ifs

func focus(boxes = []) -> void:
	Playground.focus(boxes)
	
	ColorButton.disabled = len(boxes) == 0
	RemoveButton.disabled = len(boxes) == 0
	
	if len(boxes) > 0:
		if ColorButton.button_pressed:
			ColorSliders.open( boxes[0].get_color(), "" )
	else:
		# close everything
		ColorSliders.close()

# playground

func _on_playground_fractal_changed(ifs) -> void:
	fractal_changed.emit( self.get_ifs(ifs) )

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

func _on_remove_button_pressed() -> void:
	# close rect
	await Playground.remove_current_boxes()
	focus([])
	RemoveAllButton.disabled = (len(Playground.FocusedBoxes) == 0)
	
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
