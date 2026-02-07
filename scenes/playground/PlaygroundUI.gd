extends Control

signal fractal_changed

func _on_playground_fractal_changed(ifs) -> void:
	fractal_changed.emit( ifs )
