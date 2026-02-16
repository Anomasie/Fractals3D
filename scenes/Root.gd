extends Control

@onready var PlaygroundUI = $Container/PlaygroundUI
@onready var ResultUI = $Container/ResultUI

@onready var SyncButton = $Center/SyncButton

func _ready():
	_on_sync_button_pressed()

func _on_playground_ui_fractal_changed(new_ifs) -> void:
	ResultUI.set_ifs(new_ifs)

func _on_sync_button_pressed() -> void:
	if SyncButton.button_pressed:
		Global.Cams3D[1].sync_with(Global.Cams3D[0])
		Global.Cams3D[0].sync_with(Global.Cams3D[1])
	else:
		for cam in Global.Cams3D:
			cam.sync_with(null)

func _on_playground_ui_fractal_changed_vastly( ifs : IFS ) -> void:
	_on_playground_ui_fractal_changed( ifs )
