extends HFScreen

@export var next_screen_id: HFScreenConstants.SCREENS
@export var loading_screen_id: HFScreenConstants.SCREENS


func enter(value: Variant = null) -> void:
	pass


func _on_load_screen_normal_button_pressed() -> void:
	change_screen.emit(next_screen_id)


func _on_load_screen_async_button_pressed() -> void:
	change_screen.emit(loading_screen_id, next_screen_id)
