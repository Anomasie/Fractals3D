@tool
extends MarginContainer

signal close_me
signal load_preset

var PRESETS = {
	"Sierpinski carpet": {
		"EN": "Sierpinski carpet",
		"GER": "Sierpinski-Teppich",
		"texture": "res://assets/presets/SierpinskiCarpet.png",
		"meta_data": ""
	},
	"Koch snowflake": {
		"EN": "Koch snowflake",
		"GER": "Koch-Schneeflocke",
		"texture": "res://assets/presets/KochSnowflake.png",
		"meta_data": ""
	},
	"Bernsley fern": {
		"EN": "Barnsley fern",
		"GER": "Barnsley-Farn",
		"texture": "res://assets/presets/BernsleyFern.png",
		"meta_data": ""
	}
}


@onready var Preset = load("res://scenes/presets/Preset.tscn")
@onready var CloseButton = $CloseButton
@onready var Presets = $Margin/Content/Sep/Presets
@onready var PresetLabel = $Top/Content/PresetLabel
@onready var RandomButton = $Margin/Content/Sep/RandomButton

func _ready():
	load_presets()
	# tooltips
	if not Engine.is_editor_hint():
		Global.tooltip_nodes.append_array([
			CloseButton, RandomButton
		])

func load_presets():
	# delete presets
	for child in Presets.get_children():
		if child != CloseButton:
			child.queue_free()
	# load new presets
	for preset in PRESETS.keys():
		var Instance = Preset.instantiate()
		Instance.name = preset
		# add tooltips
		if not Engine.is_editor_hint():
			if PRESETS[preset].has(Global.language):
				Instance.tooltip_text = PRESETS[preset][Global.language]
		# connect & add node
		Instance.pressed.connect(_on_preset_pressed.bind(preset))
		Presets.add_child(Instance)
		Instance.load_preset(PRESETS[preset])

func _on_preset_pressed(preset):
	if PRESETS[preset]["meta_data"]:
		load_preset.emit( IFS.from_meta_data( PRESETS[preset]["meta_data"]) )

func _on_random_button_pressed() -> void:
	load_preset.emit( IFS.random_ifs() )

func _on_close_button_pressed():
	close_me.emit()

# language & translation

func reload_language():
	match Global.language:
		"GER":
			CloseButton.tooltip_text = "Vorlagen schließen"
			PresetLabel.text = "Vorlagen"
			RandomButton.tooltip_text = "zufälliges Fraktal laden"
		_:
			CloseButton.tooltip_text = "close presets"
			PresetLabel.text = "Presets"
			RandomButton.tooltip_text = "load random ifs"
	load_presets()
