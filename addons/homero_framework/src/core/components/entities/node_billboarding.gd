class_name HFCustomNodeBillboard3D
extends Node3D

@export var absolute_billboard: bool = true

@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	if absolute_billboard:
		_mimic_camera()
	else:
		_look_at_on_y()


func _mimic_camera() -> void:
	look_at(
		global_position + camera.basis.z,
		camera.basis.y,
		true
	)


func _look_at_on_y() -> void:
	var current_y: Vector3 = global_basis.y
	look_at(
		global_position + camera.basis.z,
		global_basis.y,
		true
	)
	global_basis.y = current_y
