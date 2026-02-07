extends Node3D

@onready var Boxes = $Boxes.get_children()

func _ready():
	for i in len(Boxes):
		Boxes[i].focus_me.connect(_on_box_focus_me)

func focus(MyRects):
	for child in Boxes:
		if child is ResizableBox:
			child.set_focus( child in MyRects )

func _on_box_focus_me(box):
	focus([box])
