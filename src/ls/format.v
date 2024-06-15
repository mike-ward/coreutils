import arrays
import term
import v.mathutil

const cell_max = 12 // limit on wide displays
const cell_spacing = 3 // space between cells

struct Row {
mut:
	cells []Cell
}

struct Cell {
	content     string
	title       string
	width       int
	right_align bool
	style       Style = no_style
}

fn format(entries []Entry, args Args) []Row {
	w, _ := term.get_terminal_size()
	args_width_ok := args.width_in_cols > 0 && args.width_in_cols < 1000
	width := if args_width_ok { args.width_in_cols } else { w }

	return match true {
		args.long_format { format_long_listing(entries, args) }
		args.list_by_lines { format_by_lines(entries, width, args) }
		args.with_commas { format_with_commas(entries, args) }
		args.one_per_line { format_one_per_line(entries, args) }
		else { format_by_cells(entries, width, args) }
	}
}

fn format_by_cells(entries []Entry, width int, args Args) []Row {
	len := entries.max_name_len() + cell_spacing
	max_cols := mathutil.min(width / len, cell_max)
	partial_row := entries.len % max_cols != 0
	max_rows := entries.len / max_cols + if partial_row { 1 } else { 0 }
	mut rows := []Row{}

	for r := 0; r < max_rows; r += 1 {
		rows << Row{}
		for c := 0; c < max_cols; c += 1 {
			idx := r + c * max_rows
			if idx < entries.len {
				rows[r].cells << Cell{
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
	len := entries.max_name_len() + cell_spacing
	max_cols := mathutil.min(width / len, cell_max)
	mut rows := []Row{}

	for i, entry in entries {
		if i % max_cols == 0 {
			rows << Row{}
		}
		rows[rows.len - 1].cells << Cell{
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
			cells: [
				Cell{
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
		row[0].cells << Cell{
			content: if i < last { '${entry.name}, ' } else { entry.name }
		}
	}
	return row
}

fn print_rows(rows []Row, args Args) {
	_, h := term.get_terminal_size()
	page := if args.page_output && h > 2 { h } else { max_int }

	for i, row in rows {
		for col in row.cells {
			print_cell(col, args)
		}

		println('')

		if i % (page - 2) == 0 && i != 0 {
			print('Press enter to continue...')
			term.utf8_getchar() or {}
			term.cursor_up(1)
			term.erase_line_clear()
		}
	}
}

fn print_cell(c Cell, args Args) {
	pad := c.width - term.strip_ansi(c.content).runes().len

	if c.right_align && pad > 0 {
		print(' '.repeat(pad))
	}

	content := if args.colorize {
		style_string(c.content, c.style)
	} else {
		term.strip_ansi(c.content)
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
		entry.fifo { args.style_pi }
		entry.block { args.style_bd }
		entry.character { args.style_cd }
		entry.socket { args.style_so }
		entry.file { args.style_fi }
		else { no_style }
	}
}
