import os
import math

struct Entry {
	name      string
	dir_name  string
	stat      os.Stat
	dir       bool
	file      bool
	link      bool
	exe       bool
	origin    string
	r_size    string
	r_size_kb string
}

// Before changing this function, try some of these edge cases with GNU ls
// 		ls ../..
//      ls ../../*txt
//      ls ../..*
// the last one is particularly interesting in that it
// walks the subdirs and prints each subdir separately.
fn get_entries(args Args) []Entry {
	files := if args.files.len == 0 {
		os.ls('.') or { exit_error(err.msg()) }
	} else {
		args.files
	}

	mut entries := []Entry{}
	wd := os.getwd()
	defer { cd(wd) }

	for file in files {
		if os.is_dir(file) {
			other_files := os.ls(file) or { exit_error(err.msg()) }
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
	indicator := if is_dir && args.dir_indicator { '/' } else { '' }
	is_link := os.is_link(file)
	target := if is_link { read_link(os.abs_path(file)) } else { '' }
	return Entry{
		name: file + indicator
		dir_name: dir_name
		stat: stat
		dir: is_dir
		file: os.is_file(file)
		link: is_link
		exe: os.is_executable(file)
		origin: target
		r_size: readable_size(stat.size, false)
		r_size_kb: readable_size(stat.size, true)
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
