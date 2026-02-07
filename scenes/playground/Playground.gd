extends Node3D

signal fractal_changed
signal focus_these

@onready var Boxes = $Boxes.get_children()

var FocusedBoxes = []

func _ready():
	for i in len(Boxes):
		Boxes[i].focus_me.connect(_on_box_focus_me)
		Boxes[i].changed.connect(_on_box_changed)
	await Engine.get_main_loop().process_frame
	_on_box_changed()

func get_ifs() -> IFS:
	var my_ifs = IFS.new()
	var systems = []
	
	for box in Boxes:
		systems.append( box.get_contraction() )
	my_ifs.systems = systems
	
	return my_ifs

func focus(MyRects):
	FocusedBoxes = MyRects
	for child in Boxes:
		if child is ResizableBox:
			child.set_focus( child in FocusedBoxes )

func set_color(color : Color):
	for box in FocusedBoxes:
		box.set_color(color)

func _on_box_focus_me(box):
	focus_these.emit([box])

func _on_box_changed():
	fractal_changed.emit( self.get_ifs() )
