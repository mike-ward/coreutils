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

	print_dir_names := group_by_dir.len > 1

	for dir in group_by_dir.keys().sorted() {
		dir_entries := group_by_dir[dir]
		filtered := filter(dir_entries, args)
		sorted := sort(filtered, args)
		listing := format(sorted, args)

		if print_dir_names {
			print_dir_name(dir, args)
		}

		print_listing(listing, args)
	}
}
