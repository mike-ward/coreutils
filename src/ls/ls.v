import arrays
import os

fn main() {
	args := parse_args(os.args)
	ls(args)
}

fn ls(args Args) {
	entries := get_entries(args)

	// When results span mutiple directories, each directory is
	// presented separately. Try 'ls ../../*' to see an example
	grouped_entries := arrays.group_by[string, Entry](entries, fn (e Entry) string {
		return e.dir_name
	})

	for name, g_entries in grouped_entries {
		print_group_name(name, grouped_entries.keys().len)
		filtered := filter(g_entries, args)
		sorted := sort(filtered, args)
		rows := format(sorted, args)
		print_rows(rows, args)
	}
}
