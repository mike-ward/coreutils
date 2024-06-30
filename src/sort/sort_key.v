import strconv

enum SortOption {
	ascii
	numeric
	leading
	dictionary
	ignore_case
	ignore_non_printing
	reverse
}

struct SortKey {
	field       int
	column      int
	sort_option SortOption
}

fn sort_key(mut lines []string, options Options) {
	mut sort_keys := []SortKey{}
	for sort_key in options.sort_keys {
		sort_keys << parse_sort_key(sort_key)
	}

	lines.sort_with_compare(fn (a &string, b &string) int {
		for key in sort_keys {
		}
	})
}

fn parse_sort_key(k string) SortKey {
	mut i := 0
	mut field := 0
	mut column := 0

	// field
	for ; i < k.len; i++ {
		if k[i].is_digit() {
			continue
		}
		field = strconv.atoi(k[0..i]) or { exit_error(err.msg()) }
	}

	// column
	if k[i] == `.` {
		start := i
		for i++; i < k.len; i++ {
			if k[i].is_digit() {
				continue
			}
			column = strconv.atoi(k[start..i]) or { exit_error(err.msg()) }
		}
	}

	// sort option
	sort_type := if i < k.len { k[i] } else { space }

	sort_option := match sort_type {
		`b` { SortOption.leading }
		`d` { SortOption.dictionary }
		`f` { SortOption.ignore_case }
		`i` { SortOption.ignore_non_printing }
		`n` { SortOption.numeric }
		`r` { SortOption.reverse }
		else { SortOption.ascii }
	}

	return SortKey{
		field: field
		column: column
		sort_option: sort_option
	}
}
