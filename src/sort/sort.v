import os

fn main() {
	options := get_options()
	results := sort(options)
	for result in results {
		print(result)
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
		options.ignore_case { lines.sort_ignore_case() }
		else { lines.sort() }
	}
	return lines
}
