extends RigidBody3D

@export var move_speed: float
@export var jump_force: float
@export var step_jump_force: float

@onready var floor_step_shape_cast_3d: ShapeCast3D = $FloorStepShapeCast3D
@onready var step_shape_cast_3d: ShapeCast3D = $StepShapeCast3D
@onready var no_obstacle_shape_cast_3d: ShapeCast3D = $NoObstacleShapeCast3D

@onready var direction_arrow: Node3D = $DebugElements/DirectionArrow
@onready var velocity_arrow: Node3D = $DebugElements/VelocityArrow
@onready var camera_basis_arrow: Node3D = $DebugElements/CameraBasisY
@onready var direction_final_arrow: Node3D = $DebugElements/DirectionFinalArrow
@onready var absolute_up_arrow: Node3D = $DebugElements/AbsoluteUp
@onready var direction_projected_arrow: Node3D = $DebugElements/DirectionProjectedArrow

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var dir_list: LinkedList = LinkedList.new()
var dir_accum: Vector3

var dir_accum_threshold: float = Vector3(3.0, 0.0, 0.0).length_squared()

@onready var gravity_direction: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector"):
	set = set_gravity


func set_gravity(vector: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")) -> void:
	if !gravity_direction.is_equal_approx(vector):
		global_basis = _align_with_y(global_basis, -vector)
	gravity_direction = vector


func _align_with_y(origin_basis: Basis, new_y: Vector3) -> Basis:
	print(origin_basis, " ", new_y)
	var new_basis: Basis = Basis(origin_basis)
	var cross_prod: Vector3 = -new_basis.z.cross(new_y)
	if cross_prod.is_equal_approx(Vector3.ZERO):
		print("Cross product for X is zero, adjusting with Z")
		new_basis.z = new_basis.x.cross(new_y)
	else:
		new_basis.x = cross_prod
	new_basis.y = new_y
	new_basis = new_basis.orthonormalized()
	print(new_basis)
	return new_basis


func _physics_process(delta: float) -> void:
	var dir: Vector3 = Vector3(
		Input.get_axis("move_left", "move_right"),
		0.0,
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	var has_input: bool = dir != Vector3.ZERO
	
	var cam_basis: Basis = camera.global_basis
	var dot_camera: float = cam_basis.y.dot(global_basis.y)
	if dot_camera < -0.1 || dot_camera > 0.1:
		dir = cam_basis * dir
	
	camera_basis_arrow.look_at(camera_basis_arrow.global_position - camera.global_basis.y)
	
	direction_arrow.visible = has_input
	if direction_arrow.visible:
		direction_arrow.look_at(direction_arrow.global_position - dir, camera.global_basis.y)
	
	velocity_arrow.visible = !linear_velocity.is_equal_approx(Vector3.ZERO)
	if velocity_arrow.visible:
		var dot: float = linear_velocity.normalized().dot(-gravity_direction)
		if dot > -1.0 && dot < 1.0:
			velocity_arrow.look_at(velocity_arrow.global_position - linear_velocity, -gravity_direction)
		velocity_arrow.scale.z = linear_velocity.length()
	
	dir = (dir * Vector3(1.0, 0.0, 1.0)).normalized()
	
	direction_final_arrow.visible = has_input
	if direction_final_arrow.visible:
		direction_final_arrow.look_at(direction_final_arrow.global_position - dir, -gravity_direction)
	
	absolute_up_arrow.look_at(absolute_up_arrow.global_position - Vector3.UP, Vector3.FORWARD)
	
	if dir.is_normalized() && !Vector3.UP.is_equal_approx(-gravity_direction) && !Vector3.DOWN.is_equal_approx(-gravity_direction):
		dir = rotate_to_plane(dir, gravity_direction)
	
	direction_projected_arrow.visible = has_input
	if direction_projected_arrow.visible:
		direction_projected_arrow.look_at(direction_projected_arrow.global_position - dir, -gravity_direction)
	
	apply_central_force(dir * move_speed / 2.0)
	
	if is_on_floor():
		# Ground movement (higher acceleration).
		apply_central_force(dir * move_speed)
		
		if !dir.is_equal_approx(Vector3.ZERO):
			dir_list.push_front(dir)
			dir_accum += dir
			if dir_list.length > 10:
				dir_accum -= dir_list.pop_back()
		else:
			dir_list.destroy()
			dir_accum = Vector3.ZERO
		
		#print_rich(
			#"
			#[color=%s]Shape colliding[/color]
			#[color=%s]Dirs equals[/color]
			#[color=%s]Dir passed threshold[/color]
			#[color=%s]Step shape is colliding[/color]
			#[color=%s]Step clear is not colliding[/color]
			#Dir %s
			#Dir accum normalized %s
			#Dir accum %s" % [
			#"green" if floor_step_shape_cast_3d.is_colliding() else "red",
			#"green" if dir_accum.normalized().dot(dir) > 0.75 else "red",
			#"green" if dir_accum.length_squared() >= dir_accum_threshold else "red",
			#"green" if step_shape_cast_3d.is_colliding() else "red",
			#"green" if !no_obstacle_shape_cast_3d.is_colliding() else "red",
			#dir,
			#dir_accum.normalized(),
			#dir_accum
		#])
		
		floor_step_shape_cast_3d.target_position.x = dir.x * 0.05
		floor_step_shape_cast_3d.target_position.z = dir.z * 0.05
		
		if Input.is_action_just_pressed("jump"):
			linear_velocity = Vector3(linear_velocity.x, 0.0, linear_velocity.y) + gravity_direction * -jump_force
		elif floor_step_shape_cast_3d.is_colliding() && \
		dir_accum.normalized().dot(dir) > 0.75 && \
		dir_accum.length_squared() >= dir_accum_threshold:
			step_shape_cast_3d.target_position = step_shape_cast_3d.to_local(dir + step_shape_cast_3d.global_position) * 0.15
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
	return test_move(transform, gravity_direction * 0.01)


func rotate_to_plane(vector: Vector3, normal: Vector3) -> Vector3:
	var rotation_direction: Vector3 = Plane(Vector3.UP, 0).project(normal)
	rotation_direction *= Quaternion(Vector3.UP, -PI / 2.0)
	var angle = -Vector3.UP.angle_to(normal)
	return Quaternion(rotation_direction.normalized(), angle) * vector
