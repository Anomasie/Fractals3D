extends CSGCombiner3D

signal clicked_axis

func _on_area_100_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(1,0,0))

func _on_area_200_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(-1,0,0))

func _on_area_010_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(0,1,0))

func _on_area_020_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(0,-1,0))

func _on_area_001_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(0,0,1))

func _on_area_002_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked_axis.emit(Vector3i(0,0,-1))
