import os

struct Entry {
	name   string
	is_dir bool
}

fn get_entries(args Args) []Entry {
	paths := os.ls(args.files[0]) or { [] }
	entries := paths.map(Entry{
		name: it
		is_dir: os.is_dir(os.join_path(os.getwd(), it))
	})
	return entries
}
