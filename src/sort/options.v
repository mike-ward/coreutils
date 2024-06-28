import common
import flag
import os
import time

const app_name = 'sort'

struct Options {
	ignore_leading_blanks bool
	dictionary_order      bool
	ignore_case           bool
	general_numeric_sort  bool
	ignore_non_printing   bool
	month_sort            bool
	human_numeric_sort    bool
	numeric_sort          bool
	random_sort           bool
	random_source         string
	reverse               bool
	sort_word             string
	version_sort          bool
	// other optoins
	batch_size      string
	check_diagnose  bool
	check_quiet     bool
	compress_prog   string
	debug           bool
	files0_from     string
	sort_key        string
	merge           bool
	output_file     string
	stable          bool
	buffer_size     int
	field_separator string
	temp_dir        string
	parallel        int
	unique          bool
	zero_terminated bool
	files           []string
}

fn get_options() Options {
	mut fp := flag.new_flag_parser(os.args)
	fp.application(app_name)
	fp.version(common.coreutils_version())
	fp.skip_executable()
	fp.arguments_description('[FILE]')
	fp.description('\nWrite sorted concatenation of all FILE(s) to standard output.' +
		'\nWith no FILE, or when FILE is -, read standard input.')

	ignore_leading_blanks := fp.bool('ignore-leading-blanks', `b`, false, 'ignore leading blanks')
	dictionary_order := fp.bool('dictionary-order', `d`, false, 'consider only blanks and alphanumeric characters')
	ignore_case := fp.bool('ignore-case', `f`, false, 'fold lower case to upper case characters')
	general_numeric_sort := fp.bool('general-numeric-sort', `g`, false, 'compare according to general numerical value')
	ignore_non_printing := fp.bool('ignore-non-printing', `i`, false, 'consider only printable characters')
	month_sort := fp.bool('month-sort', `M`, false, "compare (unknown) < 'JAN' < ... < 'DEC'")
	human_numeric_sort := fp.bool('human-numeric-sort', `H`, false, 'compare human readable numbers (e.g., 2K 1G)')
	numeric_sort := fp.bool('numeric-sort', `n`, false,
		'compare according to string numerical value\n${flag.space}' +
		"see 'Sort numerically:' below")
	random_sort := fp.bool('random-sort', `R`, false, 'shuffle, but group identical keys.')
	random_source := fp.string('random-source', ` `, '', 'get random bytes from FILE')
	reverse := fp.bool('reverse', `r`, false, 'reverse the result of comparisons')
	sort_word := fp.string('sort', ` `, '',
		'sort according to WORD: general-numeric -g, human-numeric\n${flag.space}' +
		'-h, month -M, numeric -n, random -R, version -V')
	version_sort := fp.bool('version-sort', `V`, false, 'natural sort of (version) numbers within text\n\nOther options:')

	batch_size := fp.string('batch-size', ` `, '', 'merge at most NMERGE inputs at once; for more use temp files')
	check_diagnose := fp.bool('', `c`, false, 'check for sorted input; do not sort')
	check_quiet := fp.bool('', `C`, false, 'like -c, but do not report first bad line')
	compress_prog := fp.string('compress-prog', ` `, '', 'compress temporaries with PROG; decompress them with PROG -d')
	debug := fp.bool('debug', ` `, false,
		'annotate the part of the line used to sort, and warn about\n${flag.space}' +
		'questionable usage to stderr')
	files0_from := fp.string('files0_from', ` `, '',
		'read input from the files specified by\n${flag.space}' +
		'NUL-terminated names in file F;\n${flag.space}' +
		'If F is - then read names from standard input')
	sort_key := fp.string('key', `k`, '', 'sort via a key; <string> gives location and type')
	merge := fp.bool('merge', `m`, false, 'merge already sorted files; do not sort')
	output_file := fp.string('output', `o`, '', 'write result to FILE instead of standard output')
	stable := fp.bool('stable', `s`, false, 'stabilize sort by disabling last-resort comparison')
	buffer_size := fp.int('buffer-size', `S`, 0, 'use <int> for main memory buffer')
	field_separator := fp.string('field_separator', `t`, '', 'use <string> instead of non-blank to blank transition')
	temp_dir := fp.string('temporary-directory', `T`, '',
		'use <string> for temporaries, not \${TMPDIR} or /tmp;\n${flag.space}' +
		'multiple options specify multiple directories')
	parallel := fp.int('parallel', ` `, 0, 'change the number of sorts run concurrently to <int>')
	unique := fp.bool('unique', `u`, false, 'with -c, check for strict ordering;\n${flag.space}' +
		'without -c, output only the first of an equal run')
	zero_terminated := fp.bool('zero-terminated', `z`, false, 'line delimiter is NUL, not newline\n')

	fp.footer("

		KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position,
		where F is a field number and C a character position in the
		field; both are origin 1, and the stop position defaults to the
		line's end.  If neither -t nor -b is in effect, characters in a
		field are counted from the beginning of the preceding whitespace.
		OPTS is one or more single-letter ordering options [bdfgiMhnRrV],
		which override global ordering options for that key.  If no key
		is given, use the entire line as the key.  Use --debug to
		diagnose incorrect key usage.

		SIZE may be followed by the following multiplicative suffixes: %
		1% of memory, b 1, K 1024 (default), and so on for M, G, T, P, E,
		Z, Y, R, Q.

		*** WARNING *** The locale specified by the environment affects
		sort order.  Set LC_ALL=C to get the traditional sort order that
		uses native byte values.

		Sort numerically: The number begins each line and consists of
		optional blanks, an optional ‘-’ sign, and zero or more digits
		possibly separated by thousands separators, optionally followed
		by a decimal-point character and zero or more digits. An empty
		number is treated as ‘0’. Signs on zeros and leading zeros do not
		affect ordering.

		Comparison is exact; there is no rounding error.

		The LC_CTYPE locale specifies which characters are blanks and the
		LC_NUMERIC locale specifies the thousands separator and
		decimal-point character. In the C locale, spaces and tabs are
		blanks, there is no thousands separator, and ‘.’ is the decimal
		point.

		Neither a leading ‘+’ nor exponential notation is recognized. To
		compare such strings numerically, use the --general-numeric-sort
		(-g) option.".trim_indent())

	fp.footer(common.coreutils_footer())
	files := fp.finalize() or { exit_error(err.msg()) }

	return Options{
		ignore_leading_blanks: ignore_leading_blanks
		dictionary_order: dictionary_order
		ignore_case: ignore_case
		general_numeric_sort: general_numeric_sort
		ignore_non_printing: ignore_non_printing
		month_sort: month_sort
		human_numeric_sort: human_numeric_sort
		numeric_sort: numeric_sort
		random_sort: random_sort
		random_source: random_source
		reverse: reverse
		sort_word: sort_word
		version_sort: version_sort
		// other options
		batch_size: batch_size
		check_diagnose: check_diagnose
		check_quiet: check_quiet
		compress_prog: compress_prog
		debug: debug
		files0_from: files0_from
		sort_key: sort_key
		merge: merge
		output_file: output_file
		stable: stable
		buffer_size: buffer_size
		field_separator: field_separator
		temp_dir: temp_dir
		parallel: parallel
		unique: unique
		zero_terminated: zero_terminated
		files: scan_files_arg(files)
	}
}

fn scan_files_arg(files_arg []string) []string {
	mut files := []string{}
	for file in files_arg {
		if file == '-' {
			files << stdin_to_tmp()
			continue
		}
		files << file
	}
	if files.len == 0 {
		files << stdin_to_tmp()
	}
	return files
}

const tmp_pattern = '/${app_name}-tmp-'

fn stdin_to_tmp() string {
	tmp := '${os.temp_dir()}/${tmp_pattern}${time.ticks()}'
	os.create(tmp) or { exit_error(err.msg()) }
	mut f := os.open_append(tmp) or { exit_error(err.msg()) }
	defer { f.close() }
	for {
		s := os.get_raw_line()
		if s.len == 0 {
			break
		}
		f.write_string(s) or { exit_error(err.msg()) }
	}
	return tmp
}

@[noreturn]
fn exit_error(msg string) {
	common.exit_with_error_message(app_name, msg)
}
