import arrays
import os
import time
import v.mathutil { max }

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

fn format_long_listing(entries []Entry, args Args) {
	longest_inode := longest_inode_len(entries, inode_title, args)
	longest_nlink := longest_nlink_len(entries, links_title, args)
	longest_owner_name := longest_owner_name_len(entries, owner_title, args)
	longest_group_name := longest_group_name_len(entries, group_title, args)
	longest_size := longest_size_len(entries, size_title, args)
	longest_file := longest_file_name_len(entries, name_title, args)
	dim := if args.no_dim { no_style } else { dim_style }

	for idx, entry in entries {
		// spacer row
		if args.blocked_output {
			if idx % block_size == 0 && idx != 0 {
				println('')
			}
		}

		// inode
		if args.inode {
			content := if entry.invalid { unknown } else { entry.stat.inode.str() }
			print_cell(content, longest_inode, Align.right, no_style, args)
			print_space()
		}

		// permissions
		if !args.no_permissions {
			flag := file_flag(entry, args)
			print_cell(flag, 1, .left, no_style, args)
			print_space()

			content := permissions(entry, args)
			print_cell(content, permissions_title.len, .right, no_style, args)
			print_space()
		}

		// octal permissions
		if args.octal_permissions {
			content := print_octal_permissions(entry, args)
			print_cell(content, 4, .left, no_style, args)
			print_space()
		}

		// hard links
		if !args.no_hard_links {
			content := if entry.invalid { unknown } else { '${entry.stat.nlink}' }
			print_cell(content, longest_nlink, .right, dim, args)
			print_space()
		}

		// owner name
		if !args.no_owner_name {
			content := if entry.invalid { unknown } else { get_owner_name(entry.stat.uid) }
			print_cell(content, longest_owner_name, .right, dim, args)
			print_space()
		}

		// group name
		if !args.no_group_name {
			content := if entry.invalid { unknown } else { get_group_name(entry.stat.gid) }
			print_cell(content, longest_group_name, .right, dim, args)
			print_space()
		}

		// size
		if !args.no_size {
			content := match true {
				entry.invalid { unknown }
				entry.dir || entry.link || entry.socket || entry.fifo { '-' }
				args.size_ki && args.size_ki && !args.size_kb { entry.size_ki }
				args.size_kb && args.size_kb { entry.size_kb }
				else { entry.stat.size.str() }
			}
			print_cell(content, longest_size, .right, args.style_fi, args)
			print_space()
		}

		// date/time
		if !args.no_date {
			print_time(entry, args)
		}

		print_space()
		print_space()

		// file name
		print_cell(format_entry_name(entry, args), longest_file, .left, get_style_for(entry,
			args), args)
		println('')
	}

	// if args.header && rows.len > 0 {
	// 	rows.prepend(header_rows(rows[0].cells, args))
	// }

	if !args.no_count {
		statistics(entries, args)
		println('')
	}
}

// fn header_rows(cells []Cell, args Args) []Row {
// 	mut rows := []Row{}
// 	mut cols := []Cell{}
// 	dim := if args.no_dim { no_style } else { dim_style }

// 	for col in cells {
// 		cols << Cell{
// 			content: if col.title.len > 0 { col.title } else { ' ' }
// 			width: col.width
// 			right_align: col.right_align
// 			style: dim
// 		}
// 	}

// 	rows << Row{
// 		cells: cols
// 	}

// 	len := arrays.sum(cells.map(it.width)) or { 0 }

// 	rows << Row{
// 		cells: [
// 			Cell{
// 				content: '┈'.repeat(len)
// 				style: dim
// 			},
// 		]
// 	}

// 	return rows
// }

fn print_space() {
	print(' ')
}

fn statistics(entries []Entry, args Args) {
	file_count := entries.filter(it.file).len
	dir_count := entries.filter(it.dir).len
	link_count := entries.filter(it.link).len
	mut stats := ''

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

	print_cell(stats, 0, .left, no_style, args)
}

fn format_entry_name(entry Entry, args Args) string {
	name := if args.full_path {
		os.join_path(entry.dir_name, entry.name)
	} else {
		entry.name
	}

	return match true {
		entry.link { '${name} -> ${entry.link_origin}' }
		else { name }
	}
}

fn file_flag(entry Entry, args Args) string {
	return match true {
		entry.invalid { unknown }
		entry.link { style_string('l', args.style_ln) }
		entry.dir { style_string('d', args.style_di) }
		entry.exe { style_string('e', args.style_ex) }
		entry.fifo { style_string('p', args.style_pi) }
		entry.block { style_string('b', args.style_bd) }
		entry.character { style_string('c', args.style_cd) }
		entry.socket { style_string('s', args.style_so) }
		entry.file { style_string('f', args.style_fi) }
		else { ' ' }
	}
}

fn print_octal_permissions(entry Entry, args Args) string {
	mode := entry.stat.get_mode()
	return '0${mode.owner.bitmask()}${mode.group.bitmask()}${mode.others.bitmask()}'
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
	dash := style_string('-', dim)
	rr := if file_permission.read { style_string('r', args.style_ln) } else { dash }
	ww := if file_permission.write { style_string('w', args.style_fi) } else { dash }
	xx := if file_permission.execute { style_string('x', args.style_ex) } else { dash }
	return '${rr}${ww}${xx}'
}

fn print_time(entry Entry, args Args) {
	date_format := 'MMM DD YYYY HH:MM:ss'
	invalid_fmt := '????????????????????'

	date := time.unix(entry.stat.ctime)
		.local()
		.custom_format(date_format)

	dim := if args.no_dim { no_style } else { dim_style }
	content := if entry.invalid { invalid_fmt } else { date }
	print_cell(content, date_format.len, .left, dim, args)
}

fn longest_nlink_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.stat.nlink.str().len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_hard_links || !args.header { max } else { max(max, title.len) }
}

fn longest_owner_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(get_owner_name(it.stat.uid).len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_owner_name || !args.header { max } else { max(max, title.len) }
}

fn longest_group_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(get_group_name(it.stat.gid).len)
	max := arrays.max(lengths) or { 0 }
	return if args.no_group_name || !args.header { max } else { max(max, title.len) }
}

fn longest_size_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(match true {
		it.dir { 1 }
		args.size_ki && !args.size_kb { it.size_ki.len }
		args.size_kb { it.size_kb.len }
		else { it.stat.size.str().len }
	})
	max := arrays.max(lengths) or { 0 }
	return if args.no_size || !args.header { max } else { max(max, title.len) }
}

fn longest_inode_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.stat.inode.str().len)
	max := arrays.max(lengths) or { 0 }
	return if !args.inode || !args.header { max } else { max(max, title.len) }
}

fn longest_file_name_len(entries []Entry, title string, args Args) int {
	lengths := entries.map(it.name.len + it.link_origin.len + 4)
	max := arrays.max(lengths) or { 0 }
	return if !args.header { max } else { max(max, title.len) }
}
