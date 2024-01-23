class_name HFScreenDebugView
extends CanvasLayer

@onready var fps: Label = $FPS


func _ready() -> void:
	visible = OS.is_debug_build()
	set_process(visible)


func _process(_delta: float) -> void:
	fps.text = "fps: %s" % str(Performance.get_monitor(Performance.TIME_FPS))
