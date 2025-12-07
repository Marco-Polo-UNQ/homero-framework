class_name HFScreenLoader
extends Node
## Loader class for [HFScreen].
##
## Handles scene instantiation, entry, and exit logic for a single [HFScreen] instance.
## Should be used as part of the screens array in [HFScreenManager].
## Requires a valid [HFScreenConstants] class to define screen ids.
## [br][br]
## This implementation is made to circunvent Godot's caching of [PackedScene] resources
## on Engine load, ensuring a finer control over the loading process and memory usage.
## When a [PackedScene] is declared on a [annotation @GDScript.@export] variable, Godot loads
## and caches the resource on Engine start, which can lead to unwanted memory allocation.
## By declaring the scene path as a [String] and loading it manually, we can
## ensure the resource is only loaded when needed, and freed when not in use, allowing
## for better memory management in projects with many and/or bigger individual [HFScreen].

## Emitted when a request to change the screen is made.
## [param screen_id] The id of the screen to change to.
## [param value] Optional value to pass to the target screen's [method HFScreen.enter].
signal change_screen(screen_id: int, value: Variant)

## Emitted when a request to preload another screen is made.
## [param target_screen] the id of the screen to preload.
## [param confirmation_callback] the callback receiving the path to the screen to make checks against.
signal request_preload_screen(target_screen: int, confirmation_callback: Callable)

## The unique identifier for this screen.
@export var screen_id: HFScreenConstants.SCREENS

## The file path to the screen scene ([PackedScene]) to load. It must be a valid
## path to a [HFScreen] scene.
@export_file("*.tscn") var screen_path: String

## The currently loaded [HFScreen] instance.
var screen: HFScreen

# Threaded scene instancer for instancing screens asynchronously, reducing lag.
var _threaded_scene_instancer: HFThreadedSceneInstancer = HFThreadedSceneInstancer.new()


## Loads and enters the [HFScreen] scene.
## Uses [method ResourceLoader.load_threaded_get()] for threaded loading if available,
## otherwise falls back to [method @GDScript.load()].
## [param value] Optional value to pass to the screen's [method HFScreen.enter].
func enter(value: Variant = null) -> void:
	_remove_screen()
	var scene: PackedScene
	if ResourceLoader.load_threaded_get_status(screen_path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		HFLog.d("Loading via @GDScript.load")
		scene = (load(screen_path) as PackedScene)
	else:
		HFLog.d("Loading via ResourceLoader.load_threaded_get")
		scene = ResourceLoader.load_threaded_get(screen_path)
	if _threaded_scene_instancer.instance_created.is_connected(_enter_instanced_screen):
		_threaded_scene_instancer.instance_created.disconnect(_enter_instanced_screen)
	_threaded_scene_instancer.instance_created.connect(_enter_instanced_screen.bind(value))
	_threaded_scene_instancer.instantiate_scene(scene)


# Enters the given screen instance by adding it as a child and calling its
# [method HFScreen.enter].
func _enter_instanced_screen(screen_instance: Node, value: Variant = null) -> void:
	screen = screen_instance
	add_child(screen)
	screen.change_screen.connect(_on_change_screen)
	screen.request_preload_screen.connect(request_preload_screen.emit)
	screen.enter(value)


## Sends an exit notification to the current screen and frees its resources
## once the [signal HFScreen.finished_exit] is received.
func exit() -> void:
	screen.finished_exit.connect(_remove_screen)
	screen.exit()


## Calls [method ResourceLoader.load_threaded_request] and returns the screen path.
func preload_screen() -> String:
	ResourceLoader.load_threaded_request(screen_path, "PackedScene")
	return screen_path


# Handles the [signal HFScreen.change_screen] signal from the screen.
# Emits [signal change_screen] with the target screen id and optional value.
func _on_change_screen(target_screen: int, value: Variant = null) -> void:
	change_screen.emit(target_screen, value)


# Removes the current screen from the scene tree and frees it.
func _remove_screen() -> void:
	if screen:
		if is_ancestor_of(screen):
			remove_child(screen)
		screen.queue_free()
		screen = null


# Handles the [NOTIFICATION_EXIT_TREE] notification.
# Destroys the threaded scene instancer to free resources.
func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		_threaded_scene_instancer.destroy()
