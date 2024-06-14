import arrays
import os

fn main() {
	args := parse_args(os.args)
	ls(args)
}

fn ls(args Args) {
	entries := get_entries(args)

	group_by_dir := arrays.group_by[string, Entry](entries, fn (e Entry) string {
		return e.dir_name
	})

	for dir in group_by_dir.keys().sorted(a < b) {
		group_entries := group_by_dir[dir]
		if group_by_dir.keys().len > 1 {
			print_dir_name(dir, args)
		}
		filtered := filter(group_entries, args)
		sorted := sort(filtered, args)
		rows := format(sorted, args)
		print_rows(rows, args)
	}
}
