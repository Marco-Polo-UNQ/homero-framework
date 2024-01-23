class_name HFScreen
extends Node

signal change_screen(target_screen: int, value)
signal finished_exit()


func enter(value = null) -> void:
	pass


func exit() -> void:
	finished_exit.emit()
