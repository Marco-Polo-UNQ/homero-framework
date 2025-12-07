extends HFScreen

@export var default_screen: HFScreenConstants.SCREENS

@onready var animation_player: AnimationPlayer = $TransitionAnimationPlayer
@onready var progress_bar: ProgressBar = $Control/ProgressBar

var _target_screen_id: HFScreenConstants.SCREENS
var _target_screen_path: String


func _ready() -> void:
	set_process(false)


func enter(value: Variant = null) -> void:
	_target_screen_id = default_screen
	if (
		value != null &&
		typeof(value) == TYPE_INT &&
		HFScreenConstants.SCREENS.values().has(value)
	):
		_target_screen_id = value
	
	# Deferred calling so it gives time to the animation player to start
	request_preload_screen.emit.call_deferred(_target_screen_id, _screen_preload_confirmation)
	if value == _target_screen_id:
		animation_player.play(&"enter")


func _screen_preload_confirmation(screen_path: String) -> void:
	_target_screen_path = screen_path
	if animation_player.is_playing():
		await animation_player.animation_finished
	set_process(true)


func _process(delta: float) -> void:
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(
		_target_screen_path,
		progress
	)
	match status:
		# Either the async loading is succesful, or it fails and we force a
		# single-threaded loading
		ResourceLoader.THREAD_LOAD_LOADED,ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			set_process(false)
			progress_bar.value = progress_bar.max_value
			change_screen.emit(_target_screen_id)
		# Else, we handle the load in progress
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress.front()


func exit() -> void:
	animation_player.play(&"exit")


func _call_exit() -> void:
	super.exit()
