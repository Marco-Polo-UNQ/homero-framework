@tool
extends AcceptDialog
## Popup dialog for displaying version check results in the editor.

## The output message to display, with placeholders for version info.
@export_multiline var output_message: String

## Sets the message label with the current and latest version.
func enter(current_version: String, latest_version: String) -> void:
	%MessageLabel.text = output_message % [current_version, latest_version]
