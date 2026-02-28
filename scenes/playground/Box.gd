extends CSGBox3D
class_name ResizableBox

signal changed
signal changed_vastly
signal focus_me

var focused = false

var original_scale = self.scale
var original_position = Vector3.ZERO
var editing_face = Vector3.ZERO
var editing_face_rotated = Vector3.ZERO
var editing_rotation_face = Vector3.ZERO
var last_angle = 0.0
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
	$Turn001, $Turn002
]
@onready var InnerAreaMesh = $InnerArea/Mesh

func set_contraction(contraction = Contraction.new()) -> void:
	self.position = contraction.translation
	self.scale = contraction.matrix.get_scale()
	self.rotation = contraction.matrix.get_euler()
	if not InnerAreaMesh:
		await self.ready
	set_color(contraction.color)
	focus_me.emit(self)

func get_contraction() -> Contraction:
	var my_contraction = Contraction.new()
	my_contraction.translation = self.position
	my_contraction.matrix = Basis.from_euler(-self.rotation) * Basis(
		self.scale.x * Vector3(1,0,0),
		self.scale.y * Vector3(0,1,0),
		self.scale.z * Vector3(0,0,1))
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
		
		var v = editing_face_rotated
		var x = camera_direction
		var a = drag_center
		var b = camera_position
		
		var difference = ( v.dot(a-b) + x.dot(b-a) * v.dot(x) / x.dot(x) ) / ( x.dot(v)**2 / x.dot(x) - v.dot(v) )
		
		self.scale = original_scale + difference * abs(editing_face)
		self.position = original_position + difference/2 * editing_face_rotated
		
		
		#$Tester1.set_global_position(editing_face_rotated)
		
		if not Input.is_action_pressed("click"):
			editing_face = Vector3.ZERO
			editing_face_rotated = Vector3.ZERO
			changed_vastly.emit()
		else:
			changed.emit()
		
		print(self.scale)
	
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
		
		var angle = calculate_angle()
		
		var alpha = angle-last_angle
		
		if rotation_over_pi(): alpha *= -1
		
		self.rotate(rotation_face_normal, alpha)
		
			#if editing_rotation_face.x != 0:
			#	self.rotate(rotation_face_normal, -alpha)
		
		last_angle = angle
		
		if not Input.is_action_pressed("click"):
			editing_rotation_face = Vector3.ZERO
			changed_vastly.emit()
		else:
			changed.emit()

func calculate_angle() -> float:
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
	
	return angle

func rotation_over_pi() -> bool:
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
	
	return  (rotation_face_normal).dot(a.cross(b)) < 0

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

## scaling

func set_scaling_face(face_vector, event_position):
	drag_center = event_position
	original_scale = self.scale
	original_position = self.position
	editing_face = face_vector
	editing_face_rotated = Basis.from_euler(self.rotation) * face_vector

func _on_area_100_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(1,0,0), event_position)

func _on_area_200_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(-1,0,0), event_position)

func _on_area_010_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(0,1,0), event_position)

func _on_area_020_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(0,-1,0), event_position)

func _on_area_001_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(0,0,1), event_position)

func _on_area_002_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_scaling_face(Vector3(0,0,-1), event_position)

## dragging

func _on_inner_area_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		if event.double_click:
			self.scale *= -1
		else:
			drag_center = event_position
			drag_offset = event_position - self.position
			original_position = self.position
			editing_position = true

## rotating

func set_turning_face(face_vector, face_area, event_position):
	editing_rotation_face = face_vector
	drag_center = event_position
	rotation_face_normal = (face_area.get_global_position()-self.get_global_position()).normalized()
	rotation_face_center = face_area.get_global_position()#self.get_global_position() + face_area.position * self.scale
	last_angle = calculate_angle()

func _on_turn_100_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(1,0,0), FaceAreas[0], event_position)

func _on_turn_200_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(-1,0,0), FaceAreas[1], event_position)

func _on_turn_010_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(0,1,0), FaceAreas[2], event_position)

func _on_turn_020_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(0,-1,0), FaceAreas[3], event_position)

func _on_turn_001_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(0,0,1), FaceAreas[4], event_position)

func _on_turn_002_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_turning_face(Vector3(0,0,-1), FaceAreas[5], event_position)
