import arrays { group_by }
import os

fn main() {
	args := parse_args(os.args)
	ls(args)
}

fn ls(args Args) {
	entries := get_entries(args)
	group_by_dirs := group_by[string, Entry](entries, fn (e Entry) string {
		return e.dir_name
	})
	sorted_dirs := group_by_dirs.keys().sorted()

	for dir in sorted_dirs {
		filtered := filter(group_by_dirs[dir], args)
		sorted := sort(filtered, args)
		listing := format(sorted, args)
		if group_by_dirs.len > 1 {
			print_dir_name(dir, args)
		}
		print_listing(listing, args)
	}
}
