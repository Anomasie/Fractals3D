extends CSGBox3D

@onready var BoxArea = $BoxArea

var focused = false

var original_scale = Vector3(1,1,1)
var editing_face = Vector3.ZERO
var drag_center = Vector3.ZERO # point on which the face / edge was clicked

func focus():
	print("focusing!")
	focused = true
	self.material.albedo_color.a = 0.5
	BoxArea.hide()

func defocus():
	focused = false
	self.material.albedo_color.a = 1.0
	BoxArea.show()

func _process(_delta):
	if editing_face:
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		var camera_direction = get_viewport().get_camera_3d().project_ray_normal(
			get_viewport().get_mouse_position()
		)
		
		var v = editing_face
		var x = camera_direction
		var a = drag_center
		var b = camera_position
		
		var difference = 2 * ( v.dot(a-b) + x.dot(b-a) * v.dot(x) / x.dot(x) ) / ( x.dot(v)**2 / x.dot(x) - v.dot(v) )
		
		if editing_face.x != 0:
			self.scale.x = original_scale.x + difference
		if editing_face.y != 0:
			self.scale.y = original_scale.y + difference
		if editing_face.z != 0:
			self.scale.z = original_scale.z + difference
		
		if not Input.is_action_pressed("click"):
			editing_face = false

func _on_box_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		focus()

func _on_area_100_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		editing_face = Vector3(1,0,0)

func _on_area_200_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		editing_face = Vector3(-1,0,0)

func _on_area_010_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		editing_face = Vector3(0,1,0)


func _on_area_001_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		editing_face = Vector3(0,0,1)
