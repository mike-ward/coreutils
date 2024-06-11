import arrays
import os
import time

fn format_long_listing(entries []Entry, args Args) []Row {
	longest_nlink := longest_nlink_len(entries)
	longest_owner_name := longest_owner_name_len(entries)
	longest_group_name := longest_group_name_len(entries)
	longest_size := longest_size_len(entries, args.human_readable)
	longest_inode := longest_inode_len(entries)

	mut rows := []Row{}

	for entry in entries {
		mut cols := []Column{}

		// inode
		if args.inode {
			cols << Column{
				content: entry.stat.inode.str()
				width: longest_inode
				right_align: true
			}
			cols << spacer()
		}

		// permissions
		if !args.no_permissions {
			cols << Column{
				content: permissions(entry, args)
			}
		}

		// hard links
		if !args.no_hard_links {
			cols << Column{
				content: '${entry.stat.nlink}'
				width: longest_nlink
				right_align: true
			}
			cols << spacer()
		}

		// owner name
		if !args.no_owner_name {
			cols << Column{
				content: get_owner_name(entry.stat.uid)
				width: longest_owner_name
			}
			cols << spacer()
		}

		// group name
		if !args.no_group_name {
			cols << Column{
				content: get_group_name(entry.stat.gid)
				width: longest_group_name
			}
			cols << spacer()
		}

		// size
		if !args.no_size {
			cols << Column{
				content: match true {
					entry.dir { '-' }
					args.human_readable { entry.r_size }
					else { entry.stat.size.str() }
				}
				width: longest_size
				right_align: true
			}
			cols << spacer()
		}

		// date/time
		if !args.no_date {
			cols << print_time(entry, args)
		}

		cols << spacer()
		cols << spacer()

		// file name
		cols << Column{
			content: print_entry_name(entry, args)
			color: get_term_color_for(entry, args)
		}

		// create a row and add the columns
		rows << Row{
			columns: cols
		}
	}

	rows << file_count(entries.len)
	return rows
}

fn spacer() Column {
	return Column{
		content: ' '
	}
}

fn file_count(count int) Row {
	return Row{
		columns: [Column{
			content: 'count: ${count}'
		}]
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
	l := if args.colorize { color_string('l', args.ls_color_ln) } else { 'l' }
	f := if args.colorize { color_string('f', args.ls_color_fi) } else { 'f' }
	flag := match true {
		entry.link { l }
		entry.dir { d }
		entry.file { f }
		else { ' ' }
	}
	owner := file_permission(mode.owner, args)
	group := file_permission(mode.group, args)
	other := file_permission(mode.others, args)
	return '${flag} ${owner} ${group} ${other} ' // want trailing space
}

fn file_permission(file_permission os.FilePermission, args Args) string {
	r := if file_permission.read { 'r' } else { '-' }
	w := if file_permission.write { 'w' } else { '-' }
	x := if args.colorize { color_string('x', args.ls_color_ex) } else { 'x' }
	e := if file_permission.execute { x } else { '-' }
	return '${r}${w}${e}'
}

fn print_time(entry Entry, args Args) []Column {
	mut cols := []Column{}

	date := time.unix(entry.stat.ctime)
		.local()
		.custom_format('MMM DD YYYY ')

	cols << Column{
		content: date
	}

	cols << Column{
		content: time.unix(entry.stat.ctime)
			.local()
			.custom_format('HH:MM:ss')
	}

	return cols
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
		if it.dir { 1 } else { it.r_size.len }
	} else {
		if it.dir { 1 } else { it.stat.size.str().len }
	})
	return arrays.max(lengths) or { 0 }
}

fn longest_inode_len(entries []Entry) int {
	lengths := entries.map(it.stat.inode.str().len)
	return arrays.max(lengths) or { 0 }
}
