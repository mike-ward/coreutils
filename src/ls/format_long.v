import os
import time
import v.mathutil

fn format_long_listing(entries []Entry, args Args) []Row {
	longest_nlink := longest_nlink_len(entries)
	longest_owner_name := longest_owner_name_len(entries)
	longest_group_name := longest_group_name_len(entries)
	longest_size := longest_size_len(entries, args.human_readable)

	mut rows := []Row{}

	for entry in entries {
		mut cols := []Column{}
		permissions_width := 11

		// permissinos
		cols << Column{
			content: permissions(entry)
			width: permissions_width
		}

		// hard links
		cols << Column{
			content: '${entry.stat.nlink}'
			width: longest_nlink
			right_align: true
		}

		// spacer
		cols << spacer()

		// owner name
		cols << Column{
			content: get_owner_name(entry.stat.uid)
			width: longest_owner_name
		}

		// spacer
		cols << spacer()

		// group name
		cols << Column{
			content: get_group_name(entry.stat.gid)
			width: longest_group_name
		}

		// spacer
		cols << spacer()

		// size
		cols << Column{
			content: if args.human_readable { entry.r_size } else { entry.stat.size.str() }
			width: longest_size
			right_align: true
		}

		// spacer
		cols << spacer()

		// month
		tm := time.unix(entry.stat.ctime).local()
		cols << Column{
			content: tm.smonth()
			width: 4
		}

		// day
		cols << Column{
			content: tm.day.str()
			width: 2
			right_align: true
		}

		// spacer
		cols << spacer()

		// HH:MM

		cols << Column{
			content: tm.hhmm()
			width: 5
		}

		// spacer
		cols << spacer()

		// file name
		cols << Column{
			content: entry.name
		}

		// create a row and add it
		rows << Row{
			columns: cols
		}
	}
	return rows
}

fn spacer() Column {
	return Column{
		content: ' '
	}
}

fn permissions(entry Entry) string {
	mode := entry.stat.get_mode()
	d := if entry.dir { 'd' } else { '.' }
	owner := file_permission(mode.owner)
	group := file_permission(mode.group)
	other := file_permission(mode.others)
	return '${d}${owner}${group}${other}'
}

fn file_permission(file_permission os.FilePermission) string {
	r := if file_permission.read { 'r' } else { '-' }
	w := if file_permission.write { 'w' } else { '-' }
	x := if file_permission.execute { 'x' } else { '-' }
	return '${r}${w}${x}'
}

fn longest_nlink_len(entries []Entry) int {
	mut max := 0
	for entry in entries {
		max = mathutil.max(max, entry.stat.nlink.str().len)
	}
	return max
}

fn longest_owner_name_len(entries []Entry) int {
	mut max := 0
	for entry in entries {
		max = mathutil.max(max, get_owner_name(entry.stat.uid).len)
	}
	return max
}

fn longest_group_name_len(entries []Entry) int {
	mut max := 0
	for entry in entries {
		max = mathutil.max(max, get_group_name(entry.stat.gid).len)
	}
	return max
}

fn longest_size_len(entries []Entry, human_readable bool) int {
	mut max := 0
	for entry in entries {
		if human_readable {
			max = mathutil.max(max, entry.r_size.len)
		} else {
			max = mathutil.max(max, entry.stat.size.str().len)
		}
	}
	return max
}
