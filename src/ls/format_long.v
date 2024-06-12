import arrays
import v.mathutil
import os
import strings
import time

const inode_title = 'inode'
const permissions_title = 'Permissions'
const links_title = 'Links'
const owner_title = 'Owner'
const group_title = 'Group'
const size_title = 'Size'
const date_title = 'Date (modified)'
const name_title = 'Name'

fn format_long_listing(entries []Entry, args Args) []Row {
	longest_inode := longest_inode_len(entries, inode_title, args)
	longest_nlink := longest_nlink_len(entries, links_title, args)
	longest_owner_name := longest_owner_name_len(entries, owner_title, args)
	longest_group_name := longest_group_name_len(entries, group_title, args)
	longest_size := longest_size_len(entries, size_title, args)
	longest_file := longest_file_name_len(entries, name_title, args)

	mut rows := []Row{}

	for entry in entries {
		mut cols := []Column{}

		// inode
		if args.inode {
			cols << Column{
				content: entry.stat.inode.str()
				width: longest_inode
				right_align: true
				title: inode_title
			}
			cols << spacer()
		}

		// permissions
		if !args.no_permissions {
			cols << Column{
				content: file_flag(entry, args)
				width: 1
			}
			cols << spacer()

			cols << Column{
				content: permissions(entry, args)
				width: permissions_title.len
				right_align: true
				title: permissions_title
			}
			cols << spacer()
		}

		// hard links
		if !args.no_hard_links {
			cols << Column{
				content: '${entry.stat.nlink}'
				width: longest_nlink
				right_align: true
				title: links_title
			}
			cols << spacer()
		}

		// owner name
		if !args.no_owner_name {
			cols << Column{
				content: get_owner_name(entry.stat.uid)
				width: longest_owner_name
				right_align: true
				title: owner_title
			}
			cols << spacer()
		}

		// group name
		if !args.no_group_name {
			cols << Column{
				content: get_group_name(entry.stat.gid)
				width: longest_group_name
				right_align: true
				title: group_title
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
				title: size_title
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
			width: longest_file
			style: get_style_for(entry, args)
			title: name_title
		}

		// create a row and add the columns
		rows << Row{
			columns: cols
		}
	}

	if !args.no_header && rows.len > 0 {
		rows.prepend(header_rows(rows[0].columns, args))
	}

	rows << file_count(entries.len)
	return rows
}

fn header_rows(columns []Column, args Args) []Row {
	mut rows := []Row{}
	mut cols := []Column{}

	dim_style := Style{
		dim: true
		always: true
	}

	for col in columns {
		cols << Column{
			content: if col.title.len > 0 { col.title } else { ' ' }
			width: col.width
			right_align: col.right_align
			style: dim_style
		}
	}

	rows << Row{
		columns: cols
	}

	// mut uls := []Column{}
	len := arrays.sum(columns.map(it.width)) or { 0 }

	rows << Row{
		columns: [
			Column{
				content: strings.repeat_string('┈', len)
				style: dim_style
			},
		]
	}

	return rows
}

fn spacer() Column {
	return Column{
		content: ' '
		width: 1
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
		entry.link { '${entry.name} -> ${entry.link_origin}' }
		else { entry.name }
	}
}

fn file_flag(entry Entry, args Args) string {
	d := if args.colorize { style_string('d', args.style_di) } else { 'd' }
	l := if args.colorize { style_string('l', args.style_ln) } else { 'l' }
	f := if args.colorize { style_string('f', args.style_fi) } else { 'f' }
	return match true {
		entry.link { l }
		entry.dir { d }
		entry.file { f }
		else { ' ' }
	}
}

fn permissions(entry Entry, args Args) string {
	mode := entry.stat.get_mode()
	owner := file_permission(mode.owner, args)
	group := file_permission(mode.group, args)
	other := file_permission(mode.others, args)
	return '${owner} ${group} ${other}'
}

fn file_permission(file_permission os.FilePermission, args Args) string {
	r := if file_permission.read { 'r' } else { '-' }
	w := if file_permission.write { 'w' } else { '-' }
	x := if args.colorize { style_string('x', args.style_ex) } else { 'x' }
	e := if file_permission.execute { x } else { '-' }
	return '${r}${w}${e}'
}

fn print_time(entry Entry, args Args) Column {
	date_format := 'MMM DD YYYY HH:MM:ss'

	date := time.unix(entry.stat.ctime)
		.local()
		.custom_format(date_format)

	return Column{
		content: date
		width: date_format.len
		title: date_title
	}
}

fn longest_nlink_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.stat.nlink.str().len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_hard_links || args.no_header { max } else { mathutil.max(max, title.len) }
}

fn longest_owner_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(get_owner_name(it.stat.uid).len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_owner_name || args.no_header { max } else { mathutil.max(max, title.len) }
}

fn longest_group_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(get_group_name(it.stat.gid).len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_group_name || args.no_header { max } else { mathutil.max(max, title.len) }
}

fn longest_size_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(if args.human_readable {
		if it.dir { 1 } else { it.r_size.len }
	} else {
		if it.dir { 1 } else { it.stat.size.str().len }
	})
	max := arrays.max(lengths) or { 0 }
	return if args.no_size || args.no_header { max } else { mathutil.max(max, title.len) }
}

fn longest_inode_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.stat.inode.str().len)
	max := arrays.max(lengths) or { 0 }
	return if !args.inode || args.no_header { max } else { mathutil.max(max, title.len) }
}

fn longest_file_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.name.len + it.link_origin.len + 4)
	max := arrays.max(lengths) or { 0 }
	return if args.no_header { max } else { mathutil.max(max, title.len) }
}
