import os

const space = ` `
const tab = `\t`

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
		options.dictionary_order { sort_dictionary_order(mut lines, options) }
		options.ignore_case { lines.sort_ignore_case() }
		else { lines.sort() }
	}
	return lines
}

// Ignore leading blanks when finding sort keys in each line.
//  By default a blank is a space or a tab
fn sort_ignore_leading_blanks(mut lines []string, options Options) {
	lines.sort_with_compare(fn (a &string, b &string) int {
		return compare_strings(trim_leading_spaces(a), trim_leading_spaces(b))
	})
}

fn trim_leading_spaces(s string) string {
	return s.trim_left(' \n\t\v\f\r')
}

// Sort in phone directory order: ignore all characters except letters, digits
// and blanks when sorting. By default letters and digits are those of ASCII
fn sort_dictionary_order(mut lines []string, options Options) {
	lines.sort_with_compare(fn (a &string, b &string) int {
		aa := a.bytes().map(is_dictionary_char).bytestr()
		bb := b.bytes().map(is_dictionary_char).bytestr()
		return compare_strings(aa, bb)
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

// Sort numerically, first by numeric sign (negative, zero, or positive); then
// by SI suffix (either empty, or ‘k’ or ‘K’, or one of ‘MGTPEZYRQ’, in that
// order; see Block size); and finally by numeric value. For example, ‘1023M’
// sorts before ‘1G’ because ‘M’ (mega) precedes ‘G’ (giga) as an SI suffix.
// This option sorts values that are consistently scaled to the nearest
// suffix, regardless of whether suffixes denote powers of 1000 or 1024, and
// it therefore sorts the output of any single invocation of the df, du, or ls
// commands that are invoked with their --human-readable or --si options. The
// syntax for numbers is the same as for the --numeric-sort option; the SI
// suffix must immediately follow the number. To sort more accurately, you can
// use the numfmt command to reformat numbers to human format after the sort.
fn sort_human_numeric_sort(mut lines []string, options Options) {
}

// This option has no effect if the stronger --dictionary-order (-d) option
// is also given.
fn sort_ignore_non_printing(mut lines []string, options Options) {
}

// Sort numerically, first by numeric sign (negative, zero, or positive); then
// by SI suffix (either empty, or ‘k’ or ‘K’, or one of ‘MGTPEZYRQ’, in that
// order; see Block size); and finally by numeric value. For example, ‘1023M’
// sorts before ‘1G’ because ‘M’ (mega) precedes ‘G’ (giga) as an SI suffix.
// This option sorts values that are consistently scaled to the nearest
// suffix, regardless of whether suffixes denote powers of 1000 or 1024, and
// it therefore sorts the output of any single invocation of the df, du, or ls
// commands that are invoked with their --human-readable or --si options. The
// syntax for numbers is the same as for the --numeric-sort option; the SI
// suffix must immediately follow the number. To sort more accurately, you can
// use the numfmt command to reformat numbers to human format after the sort.
fn sort_human_numeric(mut lines []string, options Options) {
}

// An initial string, consisting of any amount of blanks, followed by a month
// name abbreviation, is folded to UPPER case and compared in the order ‘JAN’
// < ‘FEB’ < … < ‘DEC’. Invalid names compare low to valid names. The LC_TIME
// locale category determines the month spellings. By default a blank is a
// space or a tab, but the LC_CTYPE locale can change this
fn sort_month(mut lines []string, options Options) {
}

// Sort by version name and number. It behaves like a standard sort, except
// that each sequence of decimal digits is treated numerically as an
// index/version number.
fn sort_version(mut lines []string, options Options) {
}

// Reverse the result of comparison, so that lines with greater key values
// appear earlier in the output instead of later.
fn sort_reverse(mut lines []string, options Options) {
}
