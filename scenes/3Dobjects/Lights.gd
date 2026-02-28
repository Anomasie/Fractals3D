extends Node3D

const DEFAULT_LIGHTS_X = Color.GREEN
const DEFAULT_LIGHTS_Y = Color.BLUE
const DEFAULT_LIGHTS_Z = Color.RED

@onready var XAxis = $XAxisLight_green
@onready var YAxis = $YAxisLight_blue
@onready var ZAxis = $ZAxisLight_red

func _ready():
	set_light_colors()

func get_light_colors() -> Array:
	return [
		XAxis.light_color,
		YAxis.light_color,
		ZAxis.light_color
	]

func set_light_colors(colors = [DEFAULT_LIGHTS_X, DEFAULT_LIGHTS_Y, DEFAULT_LIGHTS_Z]) -> void:
	XAxis.light_color = colors[0]
	YAxis.light_color = colors[1]
	ZAxis.light_color = colors[2]
