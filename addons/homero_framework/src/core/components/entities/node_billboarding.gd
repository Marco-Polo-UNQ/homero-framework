class_name HFCustomNodeBillboard3D
extends Node3D

@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _process(delta: float) -> void:
	look_at(camera.global_position, Vector3.UP, true)

