extends Node3D

signal fractal_changed
signal focus_these

var FocusedBoxes = []

func _ready():
	for box in self.get_boxes():
		box.focus_me.connect(_on_box_focus_me)
		box.changed.connect(_on_box_changed)
	await Engine.get_main_loop().process_frame
	_on_box_changed()

func get_boxes() -> Array:
	var boxes = []
	for box in $Boxes.get_children():
		if box.visible:
			boxes.append(box)
	return boxes

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
