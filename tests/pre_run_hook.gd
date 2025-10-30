extends GutHookScript

const exclude_paths = [
	"res://addons/coverage/*",
	"res://addons/gut/*",
	"res://addons/homero_framework/plugin.gd",
	# NOTE: Godot may crash if you try to instrument the script that's calling instrument_scripts()
	"res://tests/*",
	"res://contrib/*"
]

func run():
	var coverage: Coverage = Coverage.new(gut.get_tree(), exclude_paths)
	coverage.instrument_scripts("res://addons/homero_framework")
