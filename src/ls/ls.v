import arrays { group_by }
import os

fn main() {
	args := parse_args(os.args)
	entries := get_entries(args.files, args)
	ls(entries, args)
}

fn ls(entries []Entry, args Args) {
	group_by_dirs := group_by[string, Entry](entries, fn (e Entry) string {
		return e.dir_name
	})
	sorted_dirs := group_by_dirs.keys().sorted()

	for dir in sorted_dirs {
		dirs := group_by_dirs[dir]
		filtered := filter(dirs, args)
		sorted := sort(filtered, args)
		listing := format(sorted, args)
		if group_by_dirs.len > 1 || args.recursive {
			print_dir_name(dir, args)
		}
		print_listing(listing, args)

		if args.recursive {
			for entry in sorted {
				if entry.dir {
					entry_path := os.join_path(entry.dir_name, entry.name)
					dir_entries := get_entries([entry_path], args)
					ls(dir_entries, args)
				}
			}
		}
	}
}
