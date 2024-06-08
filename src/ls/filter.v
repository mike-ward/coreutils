fn filter(entries []Entry, args Args) []Entry {
	if !args.all {
		return entries.filter(it.name.starts_with('../') || !it.name.starts_with('.'))
	}
	return entries
}
