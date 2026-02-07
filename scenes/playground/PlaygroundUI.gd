extends Control

signal fractal_changed

@onready var Playground = $ViewportContainer/Subviewport/Playground
# UI
## buttons
@onready var ColorButton = $Left/Main/ColorButton
## extra menüs
@onready var ColorSliders = $ColorSliders

func _ready():
	# hide and show
	ColorSliders.close()
	focus()

func focus(boxes = []) -> void:
	Playground.focus(boxes)
	if len(boxes) > 0:
		ColorButton.disabled = false
		if ColorButton.button_pressed:
			ColorSliders.open( boxes[0].get_color() )
	else:
		ColorButton.disabled = true
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
