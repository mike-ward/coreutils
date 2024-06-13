import arrays
import os

fn main() {
	args := parse_args(os.args)
	ls(args)
}

fn ls(args Args) {
	entries := get_entries(args)
	grouped_entries := group_entries(entries)

	for name, g_entries in grouped_entries {
		if grouped_entries.keys().len > 1 {
			print_dir_name(name, args)
		}
		filtered := filter(g_entries, args)
		sorted := sort(filtered, args)
		rows := format(sorted, args)
		print_rows(rows, args)
	}
}

// When entries span mutiple directories, each directory is
// presented separately.
fn group_entries(entries []Entry) map[string][]Entry {
	grouped_entries := arrays.group_by[string, Entry](entries, fn (e Entry) string {
		return e.dir_name
	})

	keys := grouped_entries.keys().sorted(a < b)
	mut sorted_grouped_entries := map[string][]Entry{}

	for key in keys {
		sorted_grouped_entries[key] = grouped_entries[key]
	}

	return sorted_grouped_entries
}
