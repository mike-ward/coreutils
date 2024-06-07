import os

struct Entry {
	name string
	stat os.Stat
	dir  bool
	file bool
	link bool
	exe  bool
}

fn get_entries(args Args) []Entry {
	ls_path := os.join_path(os.getwd(), args.files[0])
	paths := os.ls(ls_path) or { [] }

	mut entries := []Entry{}

	for path in paths {
		full_path := os.join_path(ls_path, path)
		stat := os.stat(full_path) or { continue }
		entries << Entry{
			name: path
			stat: stat
			dir: os.is_dir(full_path)
			file: os.is_file(full_path)
			link: os.is_link(full_path)
			exe: os.is_executable(full_path)
		}
	}
	return entries
}
