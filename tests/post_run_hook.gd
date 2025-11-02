extends GutHookScript

const COVERAGE_TARGET: float = 90.0
const FILE_TARGET: float = 90.0

func run():
	var coverage: Coverage = Coverage.instance
	var coverage_file: String = OS.get_environment("COVERAGE_FILE") if OS.has_environment("COVERAGE_FILE") else ""
	if coverage_file:
		coverage.save_coverage_file(coverage_file)
	coverage.set_coverage_targets(COVERAGE_TARGET, FILE_TARGET)
	Coverage.finalize(Coverage.Verbosity.FILENAMES)
	#Coverage.finalize(Coverage.Verbosity.FAILING_FILES)
	var logger = gut.get_logger()
	var coverage_passing = coverage.coverage_passing()
	var coverage_percent = coverage.coverage_percent()
	var coverage_count = coverage.coverage_count()
	var coverage_line_count = coverage.coverage_line_count()
	if !coverage_passing:
		logger.failed(
			"Coverage target not met:\nActual %.1f%% of %.1f%% total (%.1f%% file).\nLines covered %s/%s." %
			[coverage_percent, COVERAGE_TARGET, FILE_TARGET, coverage_count, coverage_line_count]
		)
		set_exit_code(2)
	else:
		gut.set_log_level(gut.LOG_LEVEL_ALL_ASSERTS)
		logger.passed(
			"Coverage target reached:\nActual %.1f%% of %.1f%% total, %.1f%% file coverage.\nLines covered %s/%s." %
			[coverage_percent, COVERAGE_TARGET, FILE_TARGET, coverage_count, coverage_line_count]
		)
