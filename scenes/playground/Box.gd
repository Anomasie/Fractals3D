extends CSGBox3D
class_name ResizableBox

signal changed
signal changed_vastly
signal focus_me

var focused = false

var original_scale = self.scale
var original_position = Vector3.ZERO
var original_rotation = 0.0
var editing_face = Vector3.ZERO
var editing_rotation_face = Vector3.ZERO
var editing_position = false
var drag_center = Vector3.ZERO # point on which the face / edge was clicked
var drag_offset = Vector3.ZERO # point inside the InnerArea that was clicked
var rotation_face_normal = Vector3.ZERO # normal of the plane which is rotated (in real space)
var rotation_face_center = Vector3.ZERO

@onready var BoxArea = $BoxArea
@onready var FaceAreas = [
	$Area100, $Area200,
	$Area010, $Area020,
	$Area001, $Area002
]
@onready var TurnAreas = [
	$Turn001
]
@onready var InnerAreaMesh = $InnerArea/Mesh

func get_contraction() -> Contraction:
	var my_contraction = Contraction.new()
	my_contraction.translation = self.position
	my_contraction.matrix = [
		[self.scale.x, 0, 0],
		[0, self.scale.y, 0],
		[0, 0, self.scale.z]
	]
	my_contraction.color = get_color()
	return my_contraction

func set_focus(value = true):
	if value: focus()
	else: defocus()

func focus():
	focused = true
	self.material.albedo_color.a = 0.5
	BoxArea.hide()
	for Area in FaceAreas:
		Area.show()
	for Area in TurnAreas:
		Area.show()

func defocus():
	focused = false
	self.material.albedo_color.a = 1.0
	BoxArea.show()
	for Area in FaceAreas:
		Area.hide()
	for Area in TurnAreas:
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
			changed_vastly.emit()
		else:
			changed.emit()
	
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
			changed_vastly.emit()
		else:
			changed.emit()
	
	elif editing_rotation_face:
		
		var camera_position = get_viewport().get_camera_3d().global_transform.origin
		var camera_direction = get_viewport().get_camera_3d().project_ray_normal(
			get_viewport().get_mouse_position()
		)
		
		var n = rotation_face_normal
		var x = drag_center
		var v = camera_direction
		var c = camera_position
		var s = (n.dot(x-c))/n.dot(v)
		
		var mouse_intersects_face = c + s * v
		var a = x - rotation_face_center
		var b = mouse_intersects_face - rotation_face_center
		var angle = acos ( (a.normalized()).dot(b.normalized()) )
		if (rotation_face_normal).dot(a.cross(b)) >= 0:
			self.rotation.z = angle + original_rotation
		else:
			self.rotation.z = - angle + original_rotation
		
		if not Input.is_action_pressed("click"):
			editing_rotation_face = Vector3.ZERO
			changed_vastly.emit()
		else:
			changed.emit()

func get_color() -> Color:
	var color = self.material.albedo_color
	color.a = 1.0
	return color

func set_color(color : Color):
	self.material.albedo_color = color
	if focused:
		self.material.albedo_color.a = 0.5
	InnerAreaMesh.mesh.material.albedo_color = color

# area signals

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
		if event.double_click:
			self.flip_faces = not self.flip_faces
		else:
			drag_center = event_position
			drag_offset = event_position - self.position
			original_position = self.position
			editing_position = true

func _on_turn_001_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		editing_rotation_face = Vector3(0,0,1)
		drag_center = event_position
		rotation_face_normal = ($Area001.get_global_position()-self.get_global_position()).normalized()
		rotation_face_center = self.get_global_position() + $Area001.position * self.scale
		original_rotation = self.rotation.z
