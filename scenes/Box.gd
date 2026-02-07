extends CSGBox3D
class_name ResizableBox

signal focus_me

@onready var BoxArea = $BoxArea

var focused = false

var original_scale = self.scale
var original_position = Vector3.ZERO
var editing_face = Vector3.ZERO
var editing_position = false
var drag_center = Vector3.ZERO # point on which the face / edge was clicked
var drag_offset = Vector3.ZERO # point inside the InnerArea that was clicked

@onready var FaceAreas = [
	$Area100, $Area200,
	$Area010, $Area020,
	$Area001, $Area002
]

func set_focus(value = true):
	if value: focus()
	else: defocus()

func focus():
	focused = true
	self.material.albedo_color.a = 0.5
	BoxArea.hide()
	for Area in FaceAreas:
		Area.show()

func defocus():
	focused = false
	self.material.albedo_color.a = 1.0
	BoxArea.show()
	for Area in FaceAreas:
		Area.hide()

func _ready():
	defocus()

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
		
		var difference = ( v.dot(a-b) + x.dot(b-a) * v.dot(x) / x.dot(x) ) / ( x.dot(v)**2 / x.dot(x) - v.dot(v) )
		
		self.scale = original_scale + difference * abs(editing_face)
		self.position = original_position + difference/2 * editing_face
		
		if not Input.is_action_pressed("click"):
			editing_face = Vector3.ZERO
	elif editing_position:
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		var camera_direction = get_viewport().get_camera_3d().project_ray_normal(
			get_viewport().get_mouse_position()
		)
		
		var v = camera_position
		var x = drag_center
		var d = camera_direction
		var s = v.dot(x-v)/v.dot(d)
		
		self.position = camera_position + s * d - drag_offset
		
		if not Input.is_action_pressed("click"):
			editing_position = false

func _on_box_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_released("click"):
		focus_me.emit(self)

func _on_area_100_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(1,0,0)

func _on_area_200_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(-1,0,0)

func _on_area_010_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(0,1,0)

func _on_area_020_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(0,-1,0)

func _on_area_001_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(0,0,1)

func _on_area_002_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		original_scale = self.scale
		original_position = self.position
		editing_face = Vector3(0,0,-1)

func _on_inner_area_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		drag_center = event_position
		drag_offset = event_position - self.position
		original_position = self.position
		editing_position = true
