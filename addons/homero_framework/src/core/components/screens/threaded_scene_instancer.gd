class_name HFThreadedSceneInstancer
extends RefCounted
## Threaded scene instancer for instancing scenes asynchronously in a separate thread.
##
## This reduces lag during scene instancing by offloading the instancing process to a separate thread.
## It emits a signal with the instance when it is created.
## Created from
## https://github.com/godotengine/godot-demo-projects/blob/3.5-9e68af3/loading/multiple_threads_loading/resource_queue.gd

## Emitted when a scene instance has been created.
signal instance_created(instance: Node)

var _thread: Thread
var _mutex: Mutex
var _sem: Semaphore

var _queue: Array = []


## Queues a scene for instancing in a separate thread.
## [param scene] The [PackedScene] to instance.
func instantiate_scene(
	scene: PackedScene
) -> void:
	_lock("queue_scene")
	if _queue.is_empty() && _thread != null:
		_unlock("queue_scene")
		_thread.wait_to_finish()
		_thread = null
		_lock("queue_scene")
	
	_queue.push_back(scene)
	_post("queue_scene")
	_unlock("queue_scene")
	if _thread == null:
		_thread = Thread.new()
		_start()


## Destroys the threaded scene instancer, waiting for the thread to finish if necessary.
func destroy() -> void:
	if _thread:
		if _thread.is_alive():
			_post("unlock")
			_thread.wait_to_finish()
		_thread = null


func _init() -> void:
	_mutex = Mutex.new()
	_sem = Semaphore.new()


func _thread_process() -> void:
	_wait("thread_process")
	_lock("process")

	while _queue.size() > 0:
		var scene: PackedScene = _queue[0]
		_unlock("process_poll")
		var instance: Node = scene.instantiate()
		_lock("process_check_queue")
		if instance:
			_queue.erase(scene)
			instance_created.emit.call_deferred(instance)
	_unlock("process")


func _start() -> void:
	_thread.start(_thread_process, 0)


func _lock(_caller: String) -> void:
	_mutex.lock()


func _unlock(_caller: String) -> void:
	_mutex.unlock()

func _post(_caller: String) -> void:
	_sem.post()


func _wait(_caller: String) -> void:
	_sem.wait()
