class_name HFLog
extends Object

const _log_format: String = "%s - Homero Framework - %s"


static func d(message: String) -> void:
	var timestamp: float = Time.get_ticks_msec() / 1000.0
	print_rich(("[color=cyan]%s[/color]" % _log_format) % [timestamp, message])


static func w(message: String) -> void:
	var timestamp: float = Time.get_ticks_msec() / 1000.0
	push_warning(_log_format % [timestamp, message])


static func e(message: String) -> void:
	var timestamp: float = Time.get_ticks_msec() / 1000.0
	push_error(_log_format % [timestamp, message])
	print_stack()
