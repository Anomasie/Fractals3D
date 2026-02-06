extends CSGBox3D

@onready var BoxArea = $BoxArea

var focused = false

func focus():
	print("focusing!")
	focused = true
	self.material.albedo_color.a = 0.5
	BoxArea.hide()

func defocus():
	focused = false
	self.material.albedo_color.a = 1.0
	BoxArea.show()

func _on_box_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		focus()

func _on_area_100_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("pressed 100!")

func _on_area_200_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("pressed 200!")
