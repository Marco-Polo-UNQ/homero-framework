extends RigidBody3D

@export var move_speed: float
@export var jump_force: float

@onready var label_3d: Label3D = $BodyPivot/Label3D
@onready var label_3d_2: Label3D = $BodyPivot/Label3D2

@onready var camera: Camera3D = get_viewport().get_camera_3d()


func _physics_process(_delta: float) -> void:
	var dir: Vector3 = Vector3()
	dir.x = Input.get_axis("move_left", "move_right")
	dir.z = Input.get_axis("move_up", "move_down")
	
	label_3d.text = str(dir)
	
	var cam_basis: Basis = camera.global_transform.basis
	cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = cam_basis * dir
	
	label_3d_2.text = str(dir)
	
	apply_central_force(dir.normalized() * move_speed / 2.0)
	
	if is_on_floor():
		# Ground movement (higher acceleration).
		apply_central_force(dir.normalized() * move_speed)

		# Jumping code.
		# It's acceptable to set `linear_velocity` here as it's only set once, rather than continuously.
		# Vertical speed is set (rather than added) to prevent jumping higher than intended.
		if Input.is_action_just_pressed("jump"):
			linear_velocity.y = jump_force


func is_on_floor():      
	return test_move(transform, Vector3.DOWN * 0.01) 
