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

// In order to match GNU ls
// 	 ./ and ../  list files without the ./ and ../ prefixes
//   ./* and ../* list files WITH the ./ and ../ prefixes
//   nothing implies ./
fn get_entries(args Args) []Entry {
	wd := os.getwd()
	defer { cd(wd) }

	files := if args.files.len == 0 {
		os.ls('.') or { exit_error(err.msg()) }
	} else {
		args.files
	}

	mut entries := []Entry{}

	for file in files {
		if os.is_dir(file) {
			other_files := os.ls(file) or { exit_error(err.msg()) }
			cd(file)
			entries << other_files.map(make_entry(it, args))
			cd(wd)
			continue
		}
		entries << make_entry(file, args)
	}
	return entries
}

fn make_entry(file string, args Args) Entry {
	stat := os.lstat(file) or { exit_error(err.msg()) }
	is_dir := os.is_dir(file)
	indicator := if is_dir && args.dir_indicator { '/' } else { '' }
	return Entry{
		name: file + indicator
		stat: stat
		dir: is_dir
		file: os.is_file(file)
		link: os.is_link(file)
		exe: os.is_executable(file)
		r_size: readable_size(stat.size, false)
	}
}

fn cd(path string) {
	os.chdir(path) or { exit_error(err.msg()) }
}

fn readable_size(size u64, si bool) string {
	kb := if si { f64(1000) } else { f64(1024) }
	mut sz := f64(size)
	for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z'] {
		if sz < kb {
			round_up := if unit.len > 0 { sz + .049999 } else { sz }
			readable := math.round_sig(round_up, 1).str().trim_string_right('.0')
			bytes := if si && unit.len > 0 { 'B' } else { '' }
			return '${readable}${unit}${bytes}'
		}
		sz /= kb
	}
	return size.str()
}
