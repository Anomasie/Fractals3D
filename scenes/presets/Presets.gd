@tool
extends MarginContainer

signal close_me
signal load_preset

var PRESETS = {
	"Sierpinski sponge": {
		"EN": "Sierpinski carpet",
		"GER": "Sierpinski-Schwamm",
		"texture": "res://assets/presets/SierpinskiSponge.png",
		"meta_data": "v0|1,1,0|000000ff,ff0000ff,00ff00ff,2524ffff|0.0,0.0,0.0,0.0,0.0,2.55254745483398|0.33300000429153,0.33300000429153,0.33300000429153,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33300000429153,0.33300000429153,0.0,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33300000429153,0.0,0.33300000429153,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.0,0.33300000429153,0.33300000429153,0.0,0.0,0.0,0.33300000429153,-0.33300000429153,-0.33300000429153,ffffff|0.0,0.33300000429153,-0.33000001311302,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.0,-0.33000001311302,-0.33000001311302,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.33000001311302,0.33000001311302,-0.33000001311302,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.33000001311302,0.0,-0.33000001311302,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.3297513127327,-0.3271207511425,-0.32915371656418,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33300000429153,-0.33000001311302,-0.33000001311302,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33300012350082,-0.33000001311302,0.33300000429153,0.0,0.0,0.0,0.33300021290779,0.33300000429153,0.33300000429153,ffffff|-0.33000010251999,0.0,0.33300006389618,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.32999986410141,0.33299988508224,0.3330000936985,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33299991488457,0.33299988508224,-0.32999995350838,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|0.33300000429153,-0.33000001311302,0.0,0.0,0.0,0.0,0.33300021290779,0.33300000429153,0.33300000429153,ffffff|0.33300000429153,0.0,-0.33000001311302,0.0,0.0,0.0,0.33300021290779,0.33300000429153,0.33300000429153,ffffff|0.0,-0.33000001311302,0.33300006389618,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.33000010251999,-0.33000001311302,0.0,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.33000001311302,-0.33000001311302,0.33300006389618,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff|-0.33000001311302,0.33300000429153,0.0,0.0,0.0,0.0,0.33300000429153,0.33300000429153,0.33300000429153,ffffff"
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
