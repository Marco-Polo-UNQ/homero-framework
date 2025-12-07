extends GutTest

const USER_PATH: String = "user://"
const TEST_SCENE_PATH: String = "user://test_screen_loader_test_scene.tscn"

var screen_loader: HFScreenLoader


func before_all() -> void:
	var node_test: HFScreen = double(HFScreen).new()
	var test_scene = PackedScene.new()
	test_scene.pack(node_test)
	ResourceSaver.save(test_scene, TEST_SCENE_PATH)
	node_test.queue_free()


func before_each() -> void:
	screen_loader = HFScreenLoader.new()
	add_child_autoqfree(screen_loader)


func after_all() -> void:
	var dir = DirAccess.open(USER_PATH)
	if dir:
		dir.remove(TEST_SCENE_PATH)


func test_screen_loader_exists() -> void:
	assert_not_null(
		screen_loader,
		"Screen Loader should instantiate and not be null"
	)


func test_screen_loader_has_a_screen_id() -> void:
	assert_eq(
		screen_loader.screen_id,
		0
	)


func test_screen_loader_has_a_screen_path() -> void:
	assert_eq(
		screen_loader.screen_path,
		""
	)


func test_screen_loader_has_no_screen_instance_initially() -> void:
	assert_null(screen_loader.screen)


func test_screen_loader_can_enter_a_screen_loading_via_load_instead_of_threaded_if_not_thread_preload() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	assert_not_null(screen_loader.screen)
	assert_true(screen_loader.is_ancestor_of(screen_loader.screen))
	assert_true(screen_loader.screen.change_screen.is_connected(screen_loader._on_change_screen))
	assert_called(screen_loader.screen.enter)


func test_screen_loader_can_enter_a_screen_loading_via_threaded_if_thread_preload_available() -> void:
	var err: int = ResourceLoader.load_threaded_request(TEST_SCENE_PATH)
	assert_eq(err, OK)
	while ResourceLoader.load_threaded_get_status(TEST_SCENE_PATH) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		# Wait for the threaded load to complete
		await get_tree().process_frame
	screen_loader.screen_path = TEST_SCENE_PATH
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	assert_not_null(screen_loader.screen)
	assert_true(screen_loader.is_ancestor_of(screen_loader.screen))
	assert_true(screen_loader.screen.change_screen.is_connected(screen_loader._on_change_screen))
	assert_called(screen_loader.screen.enter)


func test_screen_loader_can_preload_a_screen() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	var screen_path: String = screen_loader.preload_screen()
	assert_eq(
		screen_path,
		TEST_SCENE_PATH,
		"Preloaded screen path should match the screen path set in the loader"
	)
	while ResourceLoader.load_threaded_get_status(TEST_SCENE_PATH) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		# Wait for the threaded load to complete
		await get_tree().process_frame
	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(TEST_SCENE_PATH)
	assert_not_null(
		packed_scene,
		"Preloaded PackedScene should not be null after threaded loading is complete"
	)


func test_screen_loader_removes_an_existing_screen_if_calling_enter_again() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	screen_loader.enter()
	var first_screen_instance: HFScreen = screen_loader.screen
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	assert_not_same(
		first_screen_instance,
		screen_loader.screen,
		"Screen Loader should remove the existing screen and load a new instance when enter() is called again"
	)
	assert_true(!is_instance_valid(first_screen_instance) || first_screen_instance.is_queued_for_deletion())


func test_screen_loader_can_exit_a_screen() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	var screen_instance: HFScreen = screen_loader.screen
	screen_loader.exit()
	assert_true(screen_instance.finished_exit.is_connected(screen_loader._remove_screen))
	assert_called(screen_instance.exit)


func test_screen_loader_removes_screen_on_finished_exit_signal() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	var screen_instance: HFScreen = screen_loader.screen
	screen_loader.exit()
	screen_instance.finished_exit.emit()
	assert_null(screen_loader.screen)
	assert_true(screen_instance.is_queued_for_deletion())


func test_screen_loader_emits_change_screen_signal_when_screen_requests_change() -> void:
	screen_loader.screen_path = TEST_SCENE_PATH
	watch_signals(screen_loader)
	screen_loader.enter()
	await gut.get_tree().create_timer(0.1).timeout
	var screen_instance: HFScreen = screen_loader.screen
	screen_instance.change_screen.emit(2, "test_value")
	assert_signal_emitted_with_parameters(
		screen_loader.change_screen,
		[2, "test_value"]
	)
