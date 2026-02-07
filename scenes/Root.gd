extends Control

@onready var PlaygroundUI = $Container/PlaygroundUI
@onready var ResultUI = $Container/ResultUI

func _on_playground_ui_fractal_changed(new_ifs) -> void:
	ResultUI.set_ifs(new_ifs)
