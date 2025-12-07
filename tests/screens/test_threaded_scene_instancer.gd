extends GutTest

var threaded_scene_instancer: HFThreadedSceneInstancer


func before_each() -> void:
	threaded_scene_instancer = HFThreadedSceneInstancer.new()


func after_each() -> void:
	threaded_scene_instancer.destroy()


func test_threaded_scene_instancer_exists() -> void:
	assert_not_null(
		threaded_scene_instancer,
		"Threaded Scene Instancer should instantiate and not be null"
	)


func test_threaded_scene_instancer_can_instantiate_scene_in_thread() -> void:
	var test_scene = PackedScene.new()
	var test_node = Node.new()
	autoqfree(test_node)
	test_scene.pack(test_node)

	threaded_scene_instancer.instance_created.connect(func(instance: Node) -> void:
		assert_not_null(
			instance,
			"Instanced scene should not be null"
		)
		assert_true(
			instance is Node,
			"Instanced scene should be of type Node"
		)
		assert_true(
			instance != test_node,
			"Instanced scene should be a different instance than the original scene's root node"
		)
		assert_true(
			instance.get_class() == test_node.get_class(),
			"Instanced scene should be of the same class as the original scene's root node"
		)
		autoqfree(instance)
	)
	threaded_scene_instancer.instantiate_scene(test_scene)
	await threaded_scene_instancer.instance_created


func test_threaded_scene_instancer_can_queue_multiple_scenes() -> void:
	var test_scene_1 = PackedScene.new()
	var test_node_1 = Node.new()
	autoqfree(test_node_1)
	test_scene_1.pack(test_node_1)

	var test_scene_2 = PackedScene.new()
	var test_node_2 = Node2D.new()
	autoqfree(test_node_2)
	test_scene_2.pack(test_node_2)

	threaded_scene_instancer.instance_created.connect(func(instance: Node) -> void:
		assert_true(
			instance is Node,
			"Instanced scene should be of type Node"
		)
		assert_true(
			instance.get_class() == test_node_1.get_class() || instance.get_class() == test_node_2.get_class(),
			"Instanced scene should be of the same class as one of the original scenes' root nodes"
		)
		autoqfree(instance)
	)

	threaded_scene_instancer.instantiate_scene(test_scene_1)
	threaded_scene_instancer.instantiate_scene(test_scene_2)
	await threaded_scene_instancer.instance_created
	await threaded_scene_instancer.instance_created


func test_threaded_scene_instancer_can_queue_scene_after_previous_instancing() -> void:
	var test_scene_1 = PackedScene.new()
	var test_node_1 = Node.new()
	autoqfree(test_node_1)
	test_scene_1.pack(test_node_1)

	var test_scene_2 = PackedScene.new()
	var test_node_2 = Node2D.new()
	autoqfree(test_node_2)
	test_scene_2.pack(test_node_2)

	threaded_scene_instancer.instance_created.connect(func(instance: Node) -> void:
		assert_true(
			instance is Node,
			"Instanced scene should be of type Node"
		)
		assert_true(
			instance.get_class() == test_node_1.get_class() || instance.get_class() == test_node_2.get_class(),
			"Instanced scene should be of the same class as one of the original scenes' root nodes"
		)
		autoqfree(instance)
	)

	threaded_scene_instancer.instantiate_scene(test_scene_1)
	await threaded_scene_instancer.instance_created
	threaded_scene_instancer.instantiate_scene(test_scene_2)
	await threaded_scene_instancer.instance_created


func test_threaded_scene_instancer_destroy_waits_for_thread() -> void:
	var test_scene = PackedScene.new()
	var test_node = Node.new()
	autoqfree(test_node)
	test_scene.pack(test_node)
	threaded_scene_instancer.instance_created.connect(func(instance: Node) -> void:
		autoqfree(instance)
	)
	threaded_scene_instancer.instantiate_scene(test_scene)
	threaded_scene_instancer.destroy()
	await threaded_scene_instancer.instance_created
	assert_null(
		threaded_scene_instancer._thread,
		"Threaded Scene Instancer destroyed without issues after instancing a scene"
	)
