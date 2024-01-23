class_name HFScreenLoader
extends Node
## Loader class to be used as wrapper for [HFScreen] with [HFScreenManager].

signal change_screen(target_screen: int, value)

@export var screen_id: HFScreenConstants.SCREENS
@export_file("*.tscn") var screen_path: String

var screen: HFScreen


## Enter function to load the necessary [HFScreen] scene.
## Uses [method ResourceLoader.load_threaded_get()] instead of
## [method @GDScript.load()] to better support loading screens using
## [method ResourceLoader.load_threaded_request()]
func enter(value = null) -> void:
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


func exit() -> void:
	screen.finished_exit.connect(_remove_screen)
	screen.exit()


func _on_change_screen(target_screen: int, value = null) -> void:
	change_screen.emit(target_screen, value)


func _remove_screen() -> void:
	if screen:
		if is_ancestor_of(screen):
			remove_child(screen)
		screen.queue_free()
		screen = null
