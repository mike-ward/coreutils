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
const unknown = '?'
const block_size = 5

const dim_style = Style{
	dim: true
}

fn format_long_listing(entries []Entry, args Args) []Row {
	longest_inode := longest_inode_len(entries, inode_title, args)
	longest_nlink := longest_nlink_len(entries, links_title, args)
	longest_owner_name := longest_owner_name_len(entries, owner_title, args)
	longest_group_name := longest_group_name_len(entries, group_title, args)
	longest_size := longest_size_len(entries, size_title, args)
	longest_file := longest_file_name_len(entries, name_title, args)
	dim := if args.no_dim { no_style } else { dim_style }

	mut rows := []Row{}

	for idx, entry in entries {
		if args.blocked_output {
			if idx % block_size == 0 && idx != 0 {
				rows << Row{
					cells: [spacer()]
				}
			}
		}

		mut cells := []Cell{}

		// inode
		if args.inode {
			cells << Cell{
				content: if entry.invalid { unknown } else { entry.stat.inode.str() }
				width: longest_inode
				right_align: true
				title: inode_title
			}
			cells << spacer()
		}

		// permissions
		if !args.no_permissions {
			cells << Cell{
				content: file_flag(entry, args)
				width: 1
			}
			cells << spacer()

			cells << Cell{
				content: permissions(entry, args)
				width: permissions_title.len
				right_align: true
				title: permissions_title
			}
			cells << spacer()
		}

		// hard links
		if !args.no_hard_links {
			cells << Cell{
				content: if entry.invalid { unknown } else { '${entry.stat.nlink}' }
				width: longest_nlink
				right_align: true
				title: links_title
				style: dim
			}
			cells << spacer()
		}

		// owner name
		if !args.no_owner_name {
			cells << Cell{
				content: if entry.invalid { unknown } else { get_owner_name(entry.stat.uid) }
				width: longest_owner_name
				right_align: true
				title: owner_title
				style: dim
			}
			cells << spacer()
		}

		// group name
		if !args.no_group_name {
			cells << Cell{
				content: if entry.invalid { unknown } else { get_group_name(entry.stat.gid) }
				width: longest_group_name
				right_align: true
				title: group_title
				style: dim
			}
			cells << spacer()
		}

		// size
		if !args.no_size {
			cells << Cell{
				content: match true {
					entry.invalid { unknown }
					entry.dir { '-' }
					args.size_ki && args.size_ki && !args.size_kb { entry.size_ki }
					args.size_kb && args.size_kb { entry.size_kb }
					else { entry.stat.size.str() }
				}
				width: longest_size
				right_align: true
				title: size_title
				style: args.style_fi
			}
			cells << spacer()
		}

		// date/time
		if !args.no_date {
			cells << print_time(entry, args)
		}

		cells << spacer()
		cells << spacer()

		// file name
		cells << Cell{
			content: print_entry_name(entry, args)
			width: longest_file
			style: get_style_for(entry, args)
			title: name_title
		}

		// create a row and add the cells
		rows << Row{
			cells: cells
		}
	}

	if !args.no_header && rows.len > 0 {
		rows.prepend(header_rows(rows[0].cells, args))
	}

	if !args.no_count {
		rows << statistics(entries, args)
	}
	return rows
}

fn header_rows(cells []Cell, args Args) []Row {
	mut rows := []Row{}
	mut cols := []Cell{}
	dim := if args.no_dim { no_style } else { dim_style }

	for col in cells {
		cols << Cell{
			content: if col.title.len > 0 { col.title } else { ' ' }
			width: col.width
			right_align: col.right_align
			style: dim
		}
	}

	rows << Row{
		cells: cols
	}

	len := arrays.sum(cells.map(it.width)) or { 0 }

	rows << Row{
		cells: [
			Cell{
				content: strings.repeat_string('┈', len)
				style: dim
			},
		]
	}

	return rows
}

fn spacer() Cell {
	return Cell{
		content: ' '
		width: 1
	}
}

fn statistics(entries []Entry, args Args) Row {
	file_count := entries.filter(it.file).len
	dir_count := entries.filter(it.dir).len
	link_count := entries.filter(it.link).len
	mut stats := ''

	if args.colorize {
		dim := if args.no_dim { no_style } else { dim_style }
		file_count_styled := style_string(file_count.str(), args.style_fi)
		files := style_string('files', dim)
		dir_count_styled := style_string(dir_count.str(), args.style_di)
		dirs := style_string('dirs', dim)

		stats = '${file_count_styled} ${files} ${dir_count_styled} ${dirs}'
		if link_count > 0 {
			link_count_styled := style_string(link_count.str(), args.style_ln)
			links := style_string('links', dim)
			stats += ' ${link_count_styled} ${links}'
		}
	} else {
		stats = '${file_count} files ${dir_count} dirs'
		if link_count > 0 {
			stats += ' ${link_count} links'
		}
	}

	return Row{
		cells: [Cell{
			content: stats
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
		entry.invalid { unknown }
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
	dim := if args.no_dim { no_style } else { dim_style }
	dash := if args.colorize { style_string('-', dim) } else { '-' }

	rs := if args.colorize { style_string('r', args.style_ln) } else { 'r' }
	rr := if file_permission.read { rs } else { dash }

	ws := if args.colorize { style_string('w', args.style_fi) } else { 'w' }
	ww := if file_permission.write { ws } else { dash }

	xs := if args.colorize { style_string('x', args.style_ex) } else { 'x' }
	xx := if file_permission.execute { xs } else { dash }

	return '${rr}${ww}${xx}'
}

fn print_time(entry Entry, args Args) Cell {
	date_format := 'MMM DD YYYY HH:MM:ss'

	date := time.unix(entry.stat.ctime)
		.local()
		.custom_format(date_format)

	dim := if args.no_dim { no_style } else { dim_style }

	return Cell{
		content: if entry.invalid { '????????????????????' } else { date }
		width: date_format.len
		title: date_title
		style: dim
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
	lengths := entries.map(match true {
		it.dir { 1 }
		args.size_ki && !args.size_kb { it.size_ki.len }
		args.size_kb { it.size_kb.len }
		else { it.stat.size.str().len }
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
