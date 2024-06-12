import arrays
import term
import v.mathutil

const column_max = 12 // limit on wide displays
const column_spacing = 3 // space between columns

struct Row {
mut:
	columns []Column
}

struct Column {
	content     string
	title       string
	width       int
	right_align bool
	style       Style = empty_style
}

fn format(entries []Entry, args Args) []Row {
	width, _ := term.get_terminal_size()

	return match true {
		args.long_format { format_long_listing(entries, args) }
		args.list_by_lines { format_by_lines(entries, width, args) }
		args.with_commas { format_with_commas(entries, args) }
		args.one_per_line { format_one_per_line(entries, args) }
		else { format_by_columns(entries, width, args) }
	}
}

fn format_by_columns(entries []Entry, width int, args Args) []Row {
	len := entries.max_name_len() + column_spacing
	max_cols := mathutil.min(width / len, column_max)
	partial_row := entries.len % max_cols != 0
	max_rows := entries.len / max_cols + if partial_row { 1 } else { 0 }
	mut rows := []Row{}

	for r := 0; r < max_rows; r += 1 {
		rows << Row{}
		for c := 0; c < max_cols; c += 1 {
			idx := r + c * max_rows
			if idx < entries.len {
				rows[r].columns << Column{
					content: entries[idx].name
					width: len
					style: get_style_for(entries[idx], args)
				}
			}
		}
	}
	return rows
}

fn format_by_lines(entries []Entry, width int, args Args) []Row {
	len := entries.max_name_len() + column_spacing
	max_cols := mathutil.min(width / len, column_max)
	mut rows := []Row{}

	for i, entry in entries {
		if i % max_cols == 0 {
			rows << Row{}
		}
		rows[rows.len - 1].columns << Column{
			content: entry.name
			width: len
			style: get_style_for(entry, args)
		}
	}
	return rows
}

fn format_one_per_line(entries []Entry, args Args) []Row {
	mut rows := []Row{}
	for entry in entries {
		rows << Row{
			columns: [
				Column{
					content: entry.name
					style: get_style_for(entry, args)
				},
			]
		}
	}
	return rows
}

fn format_with_commas(entries []Entry, args Args) []Row {
	mut row := []Row{len: 1}
	last := entries.len - 1
	for i, entry in entries {
		row[0].columns << Column{
			content: if i < last { '${entry.name}, ' } else { entry.name }
		}
	}
	return row
}

fn print_rows(rows []Row, args Args) {
	for row in rows {
		for col in row.columns {
			print_column(col, args)
		}
		println('')
	}
}

fn print_column(c Column, args Args) {
	pad := c.width - term.strip_ansi(c.content).runes().len
	if c.right_align && pad > 0 {
		print(' '.repeat(pad))
	}

	content := if args.colorize || c.style.always {
		style_string(c.content, c.style)
	} else {
		c.content
	}
	print(content)

	if !c.right_align && pad > 0 {
		print(' '.repeat(pad))
	}
}

fn print_dir_name(name string, args Args) {
	if name.len > 0 {
		println('')
		nm := if args.colorize { style_string(name, args.style_di) } else { name }
		println('${nm}:')
	}
}

fn (entries []Entry) max_name_len() int {
	lengths := entries.map(it.name.len)
	return arrays.max(lengths) or { 0 }
}

fn get_style_for(entry Entry, args Args) Style {
	return match true {
		entry.link { args.style_ln }
		entry.dir { args.style_di }
		entry.exe { args.style_ex }
		entry.file { args.style_fi }
		else { empty_style }
	}
}
