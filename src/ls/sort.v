fn sort(entries []Entry, args Args) []Entry {
	cmp := match true {
		args.reverse {
			fn (a &Entry, b &Entry) int {
				return compare_strings(b.name, a.name)
			}
		}
		else {
			fn (a &Entry, b &Entry) int {
				return compare_strings(a.name, b.name)
			}
		}
	}

	return entries.sorted_with_compare(cmp)
}
