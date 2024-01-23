class_name HFLog
extends Object

const _log_format: String = "Homero Framework - %s"


static func d(message: String) -> void:
	print(_log_format % message)


static func w(message: String) -> void:
	push_warning(_log_format % message)


static func e(message: String) -> void:
	push_error(_log_format % message)
	print_stack()


