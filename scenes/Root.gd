extends Control

@onready var PlaygroundUI = $Container/PlaygroundUI
@onready var ResultUI = $Container/ResultUI

@onready var SyncButton = $Center/SyncButton

func _ready():
	_on_sync_button_pressed()

func set_ifs( ifs = IFS.random_ifs() ) -> void:
	PlaygroundUI.set_ifs(ifs)
	ResultUI.set_ifs(ifs, true)

func get_ifs() -> IFS:
	return ResultUI.get_ifs()

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

func _on_result_ui_store_to_url() -> void:
	store_to_url()

func store_to_url() -> void: 
	# get ifs
	var ifs = get_ifs()
	# store ifs
	var url_hash = ifs.to_meta_data()
	JavaScriptBridge.eval("location.replace(\"#%s\")" % url_hash)
	print("\tIFS meta data: \n",url_hash)


func _on_debug_edit_text_submitted(new_text: String) -> void:
	set_ifs( IFS.from_meta_data(new_text) )
