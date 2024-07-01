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
	f1          int
	c1          int
	f2          int
	c2          int
	sort_option SortOption
}

fn sort_key(mut lines []string, options Options) {
	mut sort_keys := []SortKey{}
	for sort_key in options.sort_keys {
		sort_keys << parse_sort_key(sort_key)
	}

	lines.sort_with_compare(fn [sort_keys, options] (a &string, b &string) int {
		for key in sort_keys {
			aa := find_field(a, key, options)
			bb := find_field(b, key, options)
			// println('${aa}, ${bb}')
			result := match key.sort_option {
				.numeric { 0 }
				.leading { 0 }
				.dictionary { 0 }
				.ignore_case { 0 }
				.ignore_non_printing { 0 }
				.reverse { compare_strings(bb, aa) }
				else { compare_strings(aa, bb) }
			}
			if result != 0 {
				return result
			}
		}
		return compare_strings(a, b)
	})
}

fn find_field(s string, key SortKey, options Options) string {
	parts := s.split(options.field_separator)
	start := if key.f1 < parts.len { key.f1 } else { 0 }
	end := if key.f2 >= key.f1 && key.f2 < parts.len { key.f2 } else { parts.len - 1 }
	join := if start == end { parts[start] } else { parts[start..end].join('') }
	begin := join[key.c1..]
	field := if key.c2 > 0 { begin[..-key.c2] } else { begin }
	return field
}

fn parse_sort_key(k string) SortKey {
	mut i := 0
	mut f1 := -1
	mut c1 := 0
	mut f2 := -1
	mut c2 := 0

	// field
	for ; i < k.len; i++ {
		if k[i].is_digit() {
			continue
		}
		f1 = strconv.atoi(k[0..i]) or { exit_error(err.msg()) }
		break
	}

	// column
	if k[i] == `.` {
		i += 1
		start := i
		for ; i < k.len; i++ {
			if k[i].is_digit() {
				continue
			}
			c1 = strconv.atoi(k[start..i]) or { exit_error(err.msg()) }
			break
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

	if sort_option != .ascii {
		i += 1
	}

	if i < k.len && k[i] == `,` {
		i += 1
		mut start := i
		for ; i < k.len; i++ {
			if k[i].is_digit() {
				continue
			}
			f2 = strconv.atoi(k[start..i]) or { exit_error(err.msg()) }
			break
		}

		if i < k.len && k[i] == `.` {
			i += 1
			start = i
			for ; i < k.len; i++ {
				if k[i].is_digit() {
					continue
				}
				c2 = strconv.atoi(k[start..i]) or { exit_error(err.msg()) }
				break
			}
		}
	}

	return SortKey{
		f1: f1
		c1: c1
		f2: f2
		c2: c2
		sort_option: sort_option
	}
}
