extends Node

signal event_changed(tag: String, value: bool, events_map: Dictionary)

var events_map: Dictionary = {}


func toggle_event(tag: String, value: bool) -> void:
	HFLog.d("Event toggled %s %s" % [tag, value])
	events_map[tag] = value
	event_changed.emit(tag, value, events_map)
