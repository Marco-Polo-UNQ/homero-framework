@tool
extends AcceptDialog

@export_multiline var output_message: String


func enter(current_version: String, latest_version: String) -> void:
	%MessageLabel.text = output_message % [current_version, latest_version]
