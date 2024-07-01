import common
import flag
import os
import time

const app_name = 'sort'

struct Options {
	ignore_leading_blanks bool
	dictionary_order      bool
	ignore_case           bool
	ignore_non_printing   bool
	numeric               bool
	reverse               bool
	// other optoins
	check_diagnose  bool
	check_quiet     bool
	sort_keys       []string
	field_separator string
	merge           bool
	output_file     string
	unique          bool
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
	ignore_non_printing := fp.bool('ignore-non-printing', `i`, false, 'consider only printable characters')
	numeric := fp.bool('numeric-sort', `n`, false,
		'compare according to string numerical value\n${flag.space}' +
		"see 'Sort numerically:' below")
	reverse := fp.bool('reverse', `r`, false, 'reverse the result of comparisons\n\nOther options:')

	check_diagnose := fp.bool('', `c`, false, 'check for sorted input; do not sort')
	check_quiet := fp.bool('', `C`, false, 'like -c, but do not report first bad line')
	sort_keys := fp.string_multi('key', `k`, 'sort via a key(s); <string> gives location and type')
	merge := fp.bool('merge', `m`, false, 'merge already sorted files; do not sort')
	field_separator := fp.string('', `t`, ' ', 'use <string> as field separator')
	output_file := fp.string('output', `o`, '', 'write result to FILE instead of standard output')
	unique := fp.bool('unique', `u`, false, 'with -c, check for strict ordering;\n${flag.space}' +
		'without -c, output only the first of an equal run')

	fp.footer("

		KEYDEF is F[.C][OPTS][,F[.C][OPTS]] for start and stop position,
		where F is a field number and C a character position in the
		field; both are origin 1, and the stop position defaults to the
		line's end.  If neither -t nor -b is in effect, characters in a
		field are counted from the beginning of the preceding whitespace.
		OPTS is one or more single-letter ordering options [bdfgiMhnRrV],
		which override global ordering options for that key.  If no key
		is given, use the entire line as the key.

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
		ignore_non_printing: ignore_non_printing
		numeric: numeric
		reverse: reverse
		// other options
		check_diagnose: check_diagnose
		check_quiet: check_quiet
		sort_keys: sort_keys
		field_separator: field_separator
		merge: merge
		output_file: output_file
		unique: unique
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
