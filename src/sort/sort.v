import os
import arrays

const space = ` `
const tab = `\t`

fn main() {
	options := get_options()
	results := sort(options)
	if options.output_file == '' {
		for result in results {
			println(result)
		}
	} else {
		os.write_lines(options.output_file, results) or { exit_error(err.msg()) }
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
		options.numeric { sort_general_numeric(mut lines, options) }
		options.dictionary_order { sort_dictionary_order(mut lines, options) }
		options.ignore_non_printing { sort_ignore_non_printing(mut lines, options) }
		options.ignore_leading_blanks { sort_ignore_leading_blanks(mut lines, options) }
		else { lines.sort() }
	}
	if options.unique {
		lines = arrays.distinct(lines)
	}
	return lines
}

// Ignore leading blanks when finding sort keys in each line.
//  By default a blank is a space or a tab
fn sort_ignore_leading_blanks(mut lines []string, options Options) {
	cmp := if options.reverse { compare_strings_reverse } else { compare_strings }
	lines.sort_with_compare(fn [cmp] (a &string, b &string) int {
		return cmp(a, b)
	})
}

fn trim_leading_spaces(s string) string {
	return s.trim_left(' \n\t\v\f\r')
}

fn compare_strings_reverse(a &string, b &string) int {
	return compare_strings(b, a)
}

// Sort in phone directory order: ignore all characters except letters, digits
// and blanks when sorting. By default letters and digits are those of ASCII
fn sort_dictionary_order(mut lines []string, options Options) {
	cmp := if options.reverse { compare_strings_reverse } else { compare_strings }
	lines.sort_with_compare(fn [cmp] (a &string, b &string) int {
		aa := a.bytes().map(is_dictionary_char).bytestr()
		bb := b.bytes().map(is_dictionary_char).bytestr()
		return cmp(aa, bb)
	})
}

fn is_dictionary_char(e u8) u8 {
	return match e.is_digit() || e.is_letter() || e == space || e == tab {
		true { e }
		else { space }
	}
}

// Sort numerically, converting a prefix of each line to a long double-precision
// floating point number. See Floating point numbers. Do not report overflow,
// underflow, or conversion errors. Use the following collating sequence:
// Lines that do not start with numbers (all considered to be equal).
// - NaNs (“Not a Number” values, in IEEE floating point arithmetic) in a
//   consistent but machine-dependent order.
// - Minus infinity.
// - Finite numbers in ascending numeric order (with -0 and +0 equal).
// - Plus infinity
fn sort_general_numeric(mut lines []string, options Options) {
}

// This option has no effect if the stronger --dictionary-order (-d) option
// is also given.
fn sort_ignore_non_printing(mut lines []string, options Options) {
	cmp := if options.reverse { compare_strings_reverse } else { compare_strings }
	lines.sort_with_compare(fn [cmp] (a &string, b &string) int {
		aa := a.bytes().map(is_printable).bytestr()
		bb := b.bytes().map(is_printable).bytestr()
		return cmp(aa, bb)
	})
}

fn is_printable(e u8) u8 {
	return if e >= u8(` `) || e <= u8(`~`) { e } else { space }
}
