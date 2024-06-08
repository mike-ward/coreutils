import os
import math

struct Entry {
	name   string
	stat   os.Stat
	dir    bool
	file   bool
	link   bool
	exe    bool
	r_size string
}

fn get_entries(args Args) []Entry {
	ls_path := os.join_path(os.getwd(), args.files[0])
	paths := os.ls(ls_path) or { [] }

	mut entries := []Entry{}

	for path in paths {
		full_path := os.join_path(ls_path, path)
		stat := os.stat(full_path) or { continue }
		is_dir := os.is_dir(full_path)
		entries << Entry{
			name: path + if is_dir && args.dir_indicator { '/' } else { '' }
			stat: stat
			dir: is_dir
			file: os.is_file(full_path)
			link: os.is_link(full_path)
			exe: os.is_executable(full_path)
			r_size: readable_size(stat.size, false)
		}
	}
	return entries
}

fn readable_size(size u64, si bool) string {
	kb := if si { f64(1000) } else { f64(1024) }
	bytes := if si { 'B' } else { '' }
	mut sz := f64(size)
	for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z'] {
		if sz < kb {
			round_up := if unit.len > 0 { sz + .05 } else { sz }
			readable := math.round_sig(round_up, 1).str().trim_string_right('.0')
			return '${readable}${unit}${bytes}'
		}
		sz /= kb
	}
	return size.str()
}
