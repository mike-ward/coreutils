fn sort(entries []Entry, args Args) []Entry {
	return entries.sorted_with_compare(fn (a &Entry, b &Entry) int {
		return compare_strings(a.name, b.name)
	})
}
