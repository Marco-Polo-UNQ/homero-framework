extends RigidBody3D

@export var move_speed: float
@export var jump_force: float
@export var step_jump_force: float

@onready var floor_step_shape_cast_3d: ShapeCast3D = $FloorStepShapeCast3D
@onready var step_shape_cast_3d: ShapeCast3D = $StepShapeCast3D
@onready var no_obstacle_shape_cast_3d: ShapeCast3D = $NoObstacleShapeCast3D

@onready var direction_arrow: Node3D = $DirectionArrow
@onready var input_arrow: Node3D = $InputArrow
@onready var velocity_arrow: Node3D = $VelocityArrow

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var dir_list: LinkedList = LinkedList.new()
var dir_accum: Vector3

var dir_accum_threshold: float = Vector3(3.0, 0.0, 0.0).length_squared()


func _physics_process(delta: float) -> void:
	var dir: Vector3 = Vector3(
		Input.get_axis("move_left", "move_right"),
		0.0,
		Input.get_axis("move_up", "move_down")
	)
	
	input_arrow.visible = dir != Vector3.ZERO
	if input_arrow.visible:
		var v1: Vector3 = input_arrow.basis.z.normalized()
		var v2: Vector3 = dir.normalized()
		var axis: Vector3 = v1.cross(v2).normalized()
		var angle: float = acos(v1.dot(v2))
		if axis != Vector3.ZERO:
			input_arrow.rotate(axis, angle)
	
	var cam_basis: Basis = camera.global_transform.basis
	cam_basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = (cam_basis * dir).normalized()
	
	direction_arrow.visible = input_arrow.visible
	if direction_arrow.visible:
		var v1: Vector3 = direction_arrow.basis.z.normalized()
		var v2: Vector3 = dir.normalized()
		var axis: Vector3 = v1.cross(v2).normalized()
		var angle: float = acos(v1.dot(v2)) # radians, not degrees
		if axis != Vector3.ZERO:
			direction_arrow.rotate(axis, angle)
	
	velocity_arrow.visible = !linear_velocity.is_equal_approx(Vector3.ZERO)
	if velocity_arrow.visible:
		var v1: Vector3 = velocity_arrow.basis.z.normalized()
		var v2: Vector3 = linear_velocity.normalized()
		var axis: Vector3 = v1.cross(v2).normalized()
		var angle: float = acos(v1.dot(v2)) # radians, not degrees
		if axis != Vector3.ZERO:
			velocity_arrow.rotate(axis, angle)
		velocity_arrow.scale.z = linear_velocity.length()
	
	apply_central_force(dir * move_speed / 2.0)
	
	if is_on_floor():
		# Ground movement (higher acceleration).
		apply_central_force(dir * move_speed)
		
		#var h_velocity: Vector3 = Vector3(
			#linear_velocity.x,
			#0.0,
			#linear_velocity.y
		#).normalized()
		
		if dir != Vector3.ZERO:
			dir_list.push_front(dir)
			dir_accum += dir
			if dir_list.length > 10:
				dir_accum -= dir_list.pop_back()
		else:
			dir_list.destroy()
			dir_accum = Vector3.ZERO
		
		print_rich(
			"
			[color=%s]Shape colliding[/color]
			[color=%s]Dirs equals[/color]
			[color=%s]Dir passed threshold[/color]
			[color=%s]Step shape is colliding[/color]
			[color=%s]Step clear is not colliding[/color]
			Dir %s
			Dir accum normalized %s
			Dir accum %s
			" % [
			"green" if floor_step_shape_cast_3d.is_colliding() else "red",
			"green" if dir_accum.normalized().dot(dir) > 0.75 else "red",
			"green" if dir_accum.length_squared() >= dir_accum_threshold else "red",
			"green" if step_shape_cast_3d.is_colliding() else "red",
			"green" if !no_obstacle_shape_cast_3d.is_colliding() else "red",
			dir,
			dir_accum.normalized(),
			dir_accum
		])
		
		Vector3( 1.0, -0.0, -0.0 ) == Vector3( 1.0, 0.0, 0.0 )
		
		floor_step_shape_cast_3d.target_position.x = dir.x * 0.05
		floor_step_shape_cast_3d.target_position.z = dir.z * 0.05
		
		if Input.is_action_just_pressed("jump"):
			linear_velocity.y = jump_force
		elif floor_step_shape_cast_3d.is_colliding() && dir_accum.normalized().dot(dir) > 0.75 && dir_accum.length_squared() >= dir_accum_threshold:
			step_shape_cast_3d.target_position = dir * 0.15
			step_shape_cast_3d.force_shapecast_update()
			if step_shape_cast_3d.is_colliding():
				no_obstacle_shape_cast_3d.target_position = dir * 0.075
				no_obstacle_shape_cast_3d.force_shapecast_update()
				if !no_obstacle_shape_cast_3d.is_colliding():
					var min_dir_speed: Vector3 = dir * move_speed * 0.3
					linear_velocity = Vector3(
						min_dir_speed.x,
						step_jump_force,
						min_dir_speed.z
					)


func is_on_floor():      
	return test_move(transform, Vector3.DOWN * 0.01)
