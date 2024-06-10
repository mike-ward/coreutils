import arrays
import os
import time

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
			content: permissions(entry, args)
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
			content: match true {
				entry.dir { '-' }
				args.human_readable { entry.r_size }
				else { entry.stat.size.str() }
			}
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
			content: print_entry_name(entry, args)
			color: get_term_color_for(entry, args)
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

fn print_entry_name(entry Entry, args Args) string {
	return match true {
		entry.link { '${entry.name} -> ${entry.origin}' }
		else { entry.name }
	}
}

fn permissions(entry Entry, args Args) string {
	mode := entry.stat.get_mode()
	d := if args.colorize { color_string('d', args.ls_color_di) } else { 'd' }
	dir := if entry.dir { d } else { '-' }
	owner := file_permission(mode.owner, args)
	group := file_permission(mode.group, args)
	other := file_permission(mode.others, args)
	return '${dir}${owner}${group}${other}'
}

fn file_permission(file_permission os.FilePermission, args Args) string {
	r := if file_permission.read { 'r' } else { '-' }
	w := if file_permission.write { 'w' } else { '-' }
	x := if args.colorize { color_string('x', args.ls_color_ex) } else { 'x' }
	ex := if file_permission.execute { x } else { '-' }
	return '${r}${w}${ex}'
}

fn longest_nlink_len(entries []Entry) int {
	lengths := entries.map(it.stat.nlink.str().len)
	return arrays.max(lengths) or { 0 }
}

fn longest_owner_name_len(entries []Entry) int {
	lengths := entries.map(get_owner_name(it.stat.uid).len)
	return arrays.max(lengths) or { 0 }
}

fn longest_group_name_len(entries []Entry) int {
	lengths := entries.map(get_group_name(it.stat.gid).len)
	return arrays.max(lengths) or { 0 }
}

fn longest_size_len(entries []Entry, human_readable bool) int {
	lengths := entries.map(if human_readable {
		it.r_size.len
	} else {
		it.stat.size.str().len
	})
	return arrays.max(lengths) or { 0 }
}
