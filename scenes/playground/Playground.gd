extends Node3D

var mobile = 1

func get_shift_input():
	return Vector2i.ZERO

func get_rotation_input():
	return Vector3i.ZERO

func _process(_delta):
	if mobile == 0:
		var move_input = get_shift_input()
		var rotation_input = get_rotation_input()
