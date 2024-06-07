import os
import term
import v.mathutil

const column_max = 12 // wide displays look silly otherwise
const column_spacing = 3 // space between columns

struct Row {
mut:
	columns []Column
}

struct Column {
	name  string
	width int
}

fn format(entries []Entry, args Args) []Row {
	return match true {
		args.long_format { format_long_listing(entries, args) }
		args.list_by_lines { format_by_lines(entries, args) }
		args.with_commas { format_with_commas(entries, args) }
		args.one_per_line { format_one_per_line(entries, args) }
		else { format_by_columns(entries, args) }
	}
}

fn format_long_listing(entries []Entry, args Args) []Row {
	mut rows := []Row{}
	for entry in entries {
		mut cols := []Column{}
		cols << Column{
			name: permissions(entry)
			width: 11
		}
		cols << Column{
			name: entry.name
		}
		rows << Row{columns: cols}
	}
	return rows
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

fn format_by_columns(entries []Entry, args Args) []Row {
	len := entries.max_name_len() + column_spacing
	width, _ := term.get_terminal_size()
	max_cols := mathutil.min(width / len, column_max)
	max_rows := entries.len / max_cols + 1
	mut rows := []Row{}

	for r := 0; r < max_rows; r += 1 {
		rows << Row{}
		for c := 0; c < max_cols; c += 1 {
			idx := r + c * max_rows
			if idx < entries.len {
				rows[r].columns << Column{
					name: entries[idx].name
					width: len
				}
			}
		}
	}
	return rows
}

fn format_by_lines(entries []Entry, args Args) []Row {
	len := entries.max_name_len() + column_spacing
	width, _ := term.get_terminal_size()
	max_cols := mathutil.min(width / len, column_max)
	mut rows := []Row{}

	for i, entry in entries {
		if i % max_cols == 0 {
			rows << Row{}
		}
		rows[rows.len - 1].columns << Column{
			name: entry.name
			width: len
		}
	}
	return rows
}

fn format_one_per_line(entries []Entry, args Args) []Row {
	mut rows := []Row{}
	for entry in entries {
		rows << Row{
			columns: [Column{
				name: entry.name
			}]
		}
	}
	return rows
}

fn format_with_commas(entries []Entry, args Args) []Row {
	mut row := []Row{len: 1}
	last := entries.len - 1
	for i, entry in entries {
		row[0].columns << Column{
			name: if i < last { '${entry.name}, ' } else { entry.name }
		}
	}
	return row
}

fn print_rows(rows []Row, args Args) {
	for row in rows {
		for col in row.columns {
			print_column(col)
		}
		println('')
	}
}

fn print_column(c Column) {
	print(c.name)
	pad := c.width - c.name.len
	if pad > 0 {
		print(' '.repeat(pad))
	}
}

fn (entries []Entry) max_name_len() int {
	mut max := 0
	for entry in entries {
		max = mathutil.max(entry.name.len, max)
	}
	return max
}
