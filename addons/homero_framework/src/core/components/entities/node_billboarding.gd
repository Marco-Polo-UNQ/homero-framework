class_name HFCustomNodeBillboard3D
extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	var camera_look: Vector3 = camera.basis.y
	look_at(camera.global_position, camera_look, true)

