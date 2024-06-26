import common
import flag
import os
import time

const app_name = 'sort'

struct Options {
	ignore_leading_blanks bool
	dictionary_order      bool
	ignore_case           bool
	version_sort          bool
	// other optoins
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
	version_sort := fp.bool('version-sort', `V`, false, 'natural sort of (version) numbers within text\n\nOther options:')

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
		uses native byte values.".trim_indent())

	fp.footer(common.coreutils_footer())
	files := fp.finalize() or { exit_error(err.msg()) }

	return Options{
		ignore_leading_blanks: ignore_leading_blanks
		dictionary_order: dictionary_order
		ignore_case: ignore_case
		version_sort: version_sort
		// other options
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
