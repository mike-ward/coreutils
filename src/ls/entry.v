import os
import math

struct Entry {
	name        string
	dir_name    string
	stat        os.Stat
	dir         bool
	file        bool
	link        bool
	exe         bool
	link_origin string
	size_ki     string
	size_kb     string
}

fn get_entries(args Args) []Entry {
	mut entries := []Entry{}
	wd := os.getwd()
	defer { cd(wd) }

	for file in args.files {
		if os.is_dir(file) {
			other_files := os.ls(file) or { continue }
			cd(file)
			entries << other_files.map(make_entry(it, file, args))
			cd(wd)
			continue
		}
		entries << make_entry(file, '', args)
	}
	return entries
}

fn make_entry(file string, dir_name string, args Args) Entry {
	stat := os.lstat(file) or { exit_error(err.msg()) }
	is_dir := os.is_dir(file)
	is_link := os.is_link(file)
	is_file := os.is_file(file)
	is_exe := os.is_executable(file)
	indicator := if is_dir && args.dir_indicator { '/' } else { '' }
	link_origin := if is_link { read_link(os.abs_path(file)) } else { '' }
	return Entry{
		name: file + indicator
		dir_name: dir_name
		stat: stat
		dir: is_dir
		file: is_file
		link: is_link
		exe: is_exe
		link_origin: link_origin
		size_ki: readable_size(stat.size, true)
		size_kb: readable_size(stat.size, false)
	}
}

fn cd(path string) {
	os.chdir(path) or { exit_error(err.msg()) }
}

fn readable_size(size u64, si bool) string {
	kb := if si { f64(1024) } else { f64(1000) }
	mut sz := f64(size)
	for unit in ['', 'k', 'm', 'g', 't', 'p', 'e', 'z'] {
		if sz < kb {
			readable := if unit.len == 0 {
				size.str()
			} else {
				math.round_sig(sz + .049999, 1).str()
			}
			bytes := match true {
				unit.len == 0 { '' }
				si { '' }
				else { 'b' }
			}
			return '${readable}${unit}${bytes}'
		}
		sz /= kb
	}
	return size.str()
}
