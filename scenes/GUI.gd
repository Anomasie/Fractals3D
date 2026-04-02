extends Control

@onready var PlaygroundUI = $Container/PlaygroundUI
@onready var ResultUI = $Container/ResultUI
@onready var SyncButton = $Center/SyncButton

@onready var ShareDialogue = $ShareDialogue
@onready var NotificationLabel = $Screen/NotificationLabel

var js_callback_on_url_hash_change = JavaScriptBridge.create_callback(_on_url_hash_change)

func _ready():
	# hide and show
	ShareDialogue.hide()
	NotificationLabel.hide()
	
	# camera
	_on_sync_button_pressed()
	
	# for loading urls
	await Engine.get_main_loop().process_frame
	var js_window = JavaScriptBridge.get_interface("window")
	if js_window:
		js_window.addEventListener("hashchange", js_callback_on_url_hash_change)
	try_load_from_url()

func set_ifs( ifs = IFS.random_ifs(), overwrite_ui = true ) -> void:
	PlaygroundUI.set_ifs(ifs)
	ResultUI.set_ifs(ifs, overwrite_ui)

func get_ifs() -> IFS:
	return ResultUI.get_ifs()

func store_to_url() -> void: 
	# get ifs
	var ifs = get_ifs()
	# store ifs
	var url_hash = ifs.to_meta_data()
	JavaScriptBridge.eval("location.replace(\"#%s\")" % url_hash)
	#print("\tIFS meta data: \n",url_hash)

# playground

func _on_playground_ui_fractal_changed(new_ifs) -> void:
	ResultUI.set_ifs(new_ifs)

func _on_playground_ui_fractal_changed_vastly( ifs : IFS ) -> void:
	_on_playground_ui_fractal_changed( ifs )
	store_to_url()

# camera stuff

func _on_sync_button_pressed() -> void:
	if SyncButton.button_pressed:
		Global.Cams3D[1].sync_with(Global.Cams3D[0])
		Global.Cams3D[0].sync_with(Global.Cams3D[1])
	else:
		for cam in Global.Cams3D:
			cam.sync_with(null)

# result

func _on_result_ui_store_to_url() -> void:
	store_to_url()

func _on_result_ui_share_fractal(image, ifs) -> void:
	#print(ifs.to_meta_data())
	ShareDialogue.open(image, ifs)

# url stuff

func _on_url_hash_change(_event):
	try_load_from_url()

func try_load_from_url():
	var url_hash = JavaScriptBridge.get_interface("location")
	if url_hash:
		var url_str = url_hash["hash"].get_slice("#", 1)#.percent_decode()
		try_load_from_string(url_str)

func try_load_from_link(url_link="#"):
	if url_link.find("#") >= 0:
		try_load_from_string(url_link.get_slice("#", 1))

func try_load_from_string(meta_data):
	if meta_data:
		# build code
		var meta_ifs = IFS.from_meta_data(meta_data)
		# valid -> build
		if meta_ifs is IFS:
			set_ifs(meta_ifs, true)

# notifications

func show_alert(message : String, wait_time = true) -> void:
	NotificationLabel.text = message
	NotificationLabel.show()
	if wait_time:
		await wait()
	else:
		await get_tree().process_frame
	NotificationLabel.hide()

func wait(seconds : float = 2.5) -> void:
	if seconds <= 0.0:
		return
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = seconds
	self.add_child(timer)
	await timer.timeout
	timer.queue_free()
	return

func _on_share_dialogue_sent_successfully() -> void:
	show_alert("Your fractal has been sent to the gallery successfully.")

func _on_share_dialogue_sent_unsuccessfully(error_code) -> void:
	match error_code:
		3:
			show_alert("Error: Could not connect to gallery, probably due to failing of the internet connection.")
		_:
			show_alert("Error: Could not send fractal to gallery. Code " + error_code)

func _on_share_dialogue_sent_away() -> void:
	show_alert("Sending fractal to gallery ...")

func _on_share_dialogue_no_connection_to_server(result) -> void:
	show_alert("Error: Could not connect to HTTP server.")

# debug area

func _on_debug_edit_text_submitted(new_text: String) -> void:
	print("text on debug edit submitted!")
	try_load_from_link(new_text)
	print("text on debug edit submission process ended!")
