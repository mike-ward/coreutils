import os

fn main() {
	options := get_options()
	results := sort(options)
	for result in results {
		println(result)
	}
}

fn sort(options Options) []string {
	mut results := []string{}
	for file in options.files {
		results << do_sort(file, options)
	}
	return results
}

fn do_sort(file string, options Options) []string {
	mut lines := os.read_lines(file) or { exit_error(err.msg()) }
	match true {
		options.ignore_leading_blanks { sort_ignore_leading_blanks(mut lines, options) }
		options.ignore_case { lines.sort_ignore_case() }
		else { lines.sort() }
	}
	return lines
}

fn sort_ignore_leading_blanks(mut lines []string, options Options) {
	lines.sort_with_compare(fn (a &string, b &string) int {
		return compare_strings(trim_leading_spaces(a), trim_leading_spaces(b))
	})
}

fn trim_leading_spaces(s string) string {
	return s.trim_left(' \n\t\v\f\r')
}
