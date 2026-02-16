extends Node3D

const DEFAULT_LIGHTS_X = Color.GREEN
const DEFAULT_LIGHTS_Y = Color.BLUE
const DEFAULT_LIGHTS_Z = Color.RED

@onready var XAxis = $XAxisLight_green
@onready var YAxis = $YAxisLight_blue
@onready var ZAxis = $ZAxisLight_red

func _ready():
	XAxis.light_color = DEFAULT_LIGHTS_X
	YAxis.light_color = DEFAULT_LIGHTS_Y
	ZAxis.light_color = DEFAULT_LIGHTS_Z
