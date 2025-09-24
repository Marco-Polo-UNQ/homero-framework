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

## The unique identifier for this screen.
@export var screen_id: HFScreenConstants.SCREENS

## The file path to the screen scene ([PackedScene]) to load. It must be a valid
## path to a [HFScreen] scene.
@export_file("*.tscn") var screen_path: String

## The currently loaded [HFScreen] instance.
var screen: HFScreen


## Loads and enters the [HFScreen] scene.
## Uses [method ResourceLoader.load_threaded_get()] for threaded loading if available,
## otherwise falls back to [method @GDScript.load()].
## [param value] Optional value to pass to the screen's [method HFScreen.enter].
func enter(value: Variant = null) -> void:
	_remove_screen()
	if ResourceLoader.load_threaded_get_status(screen_path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		HFLog.d("Loading via @GDScript.load")
		screen = (load(screen_path) as PackedScene).instantiate() as HFScreen
	else:
		HFLog.d("Loading via ResourceLoader.load_threaded_get")
		var scene: PackedScene = ResourceLoader.load_threaded_get(screen_path)
		screen = scene.instantiate() as HFScreen
	add_child(screen)
	screen.change_screen.connect(_on_change_screen)
	screen.enter(value)


## Sends an exit notification to the current screen and frees its resources
## once the [signal HFScreen.finished_exit] is received.
func exit() -> void:
	screen.finished_exit.connect(_remove_screen)
	screen.exit()


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
