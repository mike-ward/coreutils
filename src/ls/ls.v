import arrays { group_by }
import os

fn main() {
	args := parse_args(os.args)
	entries := get_entries(args)
	mut visited := []string{}
	ls(entries, args, mut visited)
}

fn ls(entries []Entry, args Args, mut visited []string) {
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
					if !already_visited(entry.name, mut visited) {
						dir_entries := get_files([
							os.join_path(entry.dir_name, entry.name),
						], args)
						ls(dir_entries, args, mut visited)
					}
				}
			}
		}
	}
}

fn already_visited(path string, mut visited []string) bool {
	abs_path := os.abs_path(path)
	if abs_path in visited {
		return true
	}
	visited << abs_path
	return false
}
