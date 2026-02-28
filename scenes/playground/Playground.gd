extends Node3D

signal fractal_changed
signal focus_these

@onready var CameraMan = $CameraManP
@onready var Boxes = $Boxes

var FocusedBoxes = []

func _ready():
	for box in self.get_boxes():
		box.focus_me.connect(_on_box_focus_me)
		box.changed.connect(_on_box_changed)
	await Engine.get_main_loop().process_frame
	_on_box_changed()

# box functions

var counter = 0

func add_box(contraction = null) -> void:
	if not contraction:
		contraction = Contraction.new()
		contraction.translation = Vector3(0.5,0,0).rotated(Vector3.UP, counter)
		counter += 1
	var box = load("res://scenes/playground/Box.tscn").instantiate()
	box.set_contraction(contraction)
	box.focus_me.connect(_on_box_focus_me)
	box.changed.connect(_on_box_changed)
	Boxes.add_child(box)

func get_boxes() -> Array:
	var boxes = []
	for box in Boxes.get_children():
		if box.visible:
			boxes.append(box)
	return boxes

func set_ifs(ifs = IFS.new()) -> void:
	FocusedBoxes = get_boxes()
	remove_current_boxes()
	
	for system in ifs.systems:
		add_box(system)

func get_ifs() -> IFS:
	var my_ifs = IFS.new()
	var systems = []
	
	for box in self.get_boxes():
		if box.visible:
			systems.append( box.get_contraction() )
	my_ifs.systems = systems
	
	return my_ifs

func focus(MyRects):
	FocusedBoxes = MyRects
	for child in self.get_boxes():
		if child is ResizableBox:
			child.set_focus( child in FocusedBoxes )

func set_color(color : Color):
	for box in FocusedBoxes:
		box.set_color(color)

func remove_current_boxes():
	for box in FocusedBoxes:
		box.hide()
		box.queue_free()
	FocusedBoxes = []

func _on_box_focus_me(box):
	focus_these.emit([box])

func _on_box_changed():
	fractal_changed.emit( self.get_ifs() )

# camera and coordinates functions

func _on_coordinates_clicked_axis(axis) -> void:
	var rot = Vector3.ZERO
	if axis.y != 0:
		rot.x = -axis.y*PI/2
		rot.y = CameraMan.rotation.y
	else:
		rot.y = axis.x*PI/2 + int(axis.z < 0)*PI
	CameraMan.load_data(rot, null, true)
