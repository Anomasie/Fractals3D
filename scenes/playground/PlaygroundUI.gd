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

func _ready():
	# hide and show
	ColorSliders.close()
	focus()

func focus(boxes = []) -> void:
	Playground.focus(boxes)
	
	ColorButton.disabled = len(boxes) == 0
	RemoveButton.disabled = len(boxes) == 0
	
	if len(boxes) > 0:
		if ColorButton.button_pressed:
			ColorSliders.open( boxes[0].get_color() )
	else:
		# close everything
		ColorSliders.close()

# playground

func _on_playground_fractal_changed(ifs) -> void:
	fractal_changed.emit( ifs )

func _on_playground_focus_these(boxes) -> void:
	focus(boxes)

# buttons

func _on_color_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if len(Playground.FocusedBoxes) > 0:
			ColorSliders.open( Playground.FocusedBoxes[0].get_color() )
	else:
		ColorSliders.close()

# color sliders

func _on_color_sliders_finished() -> void:
	ColorButton.button_pressed = false
	ColorSliders.close()

func _on_color_sliders_color_changed() -> void:
	Playground.set_color( ColorSliders.get_color() )


func _on_remove_button_pressed() -> void:
	# close rect
	await Playground.remove_current_boxes()
	focus([])
	RemoveAllButton.disabled = (len(Playground.FocusedBoxes) == 0)
	
	fractal_changed_vastly.emit( Playground.get_ifs() )
