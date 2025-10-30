extends GutHookScript

const COVERAGE_TARGET := 75.0
const FILE_TARGET := 33.0

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
	if !coverage_passing:
		logger.failed("Coverage target of %.1f%% total (%.1f%% file) was not met" % [COVERAGE_TARGET, FILE_TARGET])
		set_exit_code(2)
	else:
		gut.set_log_level(gut.LOG_LEVEL_ALL_ASSERTS)
		logger.passed("Coverage target of %.1f%% total, %.1f%% file coverage" % [COVERAGE_TARGET, FILE_TARGET])
