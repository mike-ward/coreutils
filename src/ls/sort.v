import arrays
import os

fn sort(entries []Entry, args Args) []Entry {
	cmp := match true {
		args.sort_none {
			fn (a &Entry, b &Entry) int {
				return 0
			}
		}
		args.sort_size {
			fn (a &Entry, b &Entry) int {
				return match true {
					a.stat.size < b.stat.size { 1 }
					a.stat.size > b.stat.size { -1 }
					else { compare_strings(a.name, b.name) }
				}
			}
		}
		args.sort_time {
			fn (a &Entry, b &Entry) int {
				return match true {
					a.stat.ctime < b.stat.ctime { 1 }
					a.stat.ctime > b.stat.ctime { -1 }
					else { compare_strings(a.name, b.name) }
				}
			}
		}
		args.sort_width {
			fn (a &Entry, b &Entry) int {
				result := a.name.len - b.name.len
				return if result != 0 { result } else { compare_strings(a.name, b.name) }
			}
		}
		args.sort_natural {
			fn (a &Entry, b &Entry) int {
				return natural_compare(a.name, b.name)
			}
		}
		args.sort_ext {
			fn (a &Entry, b &Entry) int {
				result := compare_strings(os.file_ext(a.name), os.file_ext(b.name))
				return if result != 0 { result } else { compare_strings(a.name, b.name) }
			}
		}
		else {
			fn (a &Entry, b &Entry) int {
				return compare_strings(a.name, b.name)
			}
		}
	}

	mut sorted := []Entry{}
	gentries := arrays.group_by[string, Entry](entries, fn [args] (e Entry) string {
		return if args.dirs_first && e.dir { 'dir' } else { 'file' }
	})

	for key in gentries.keys().sorted() {
		sorted << gentries[key].sorted_with_compare(cmp)
	}

	return if args.sort_reverse { sorted.reverse() } else { sorted }
}
