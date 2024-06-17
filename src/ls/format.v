import arrays
import term
import v.mathutil

const cell_max = 12 // limit on wide displays
const cell_spacing = 3 // space between cells

enum Align {
	left
	right
}

fn format(entries []Entry, args Args) {
	w, _ := term.get_terminal_size()
	args_width_ok := args.width_in_cols > 0 && args.width_in_cols < 1000
	width := if args_width_ok { args.width_in_cols } else { w }

	match true {
		args.long_format { format_long_listing(entries, args) }
		args.list_by_lines { format_by_lines(entries, width, args) }
		args.with_commas { format_with_commas(entries, args) }
		args.one_per_line { format_one_per_line(entries, args) }
		else { format_by_cells(entries, width, args) }
	}
}

fn format_by_cells(entries []Entry, width int, args Args) {
	len := entries.max_name_len() + cell_spacing
	max_cols := mathutil.min(width / len, cell_max)
	partial_row := entries.len % max_cols != 0
	max_rows := entries.len / max_cols + if partial_row { 1 } else { 0 }

	for r := 0; r < max_rows; r += 1 {
		mut output := ''
		for c := 0; c < max_cols; c += 1 {
			idx := r + c * max_rows
			if idx < entries.len {
				entry := entries[idx]
				output += print_cell(entry.name, len, .left, get_style_for(entry, args),
					args)
			}
		}
		println(output)
	}
}

fn format_by_lines(entries []Entry, width int, args Args) {
	len := entries.max_name_len() + cell_spacing
	max_cols := mathutil.min(width / len, cell_max)
	mut output := ''

	for i, entry in entries {
		if i % max_cols == 0 && i != 0 {
			println(output)
			output = ''
		}
		output += print_cell(entry.name, len, .left, get_style_for(entry, args), args)
	}
	if entries.len % max_cols != 0 {
		println(output)
	}
}

fn format_one_per_line(entries []Entry, args Args) {
	for entry in entries {
		println(print_cell(entry.name, 0, .left, get_style_for(entry, args), args))
	}
}

fn format_with_commas(entries []Entry, args Args) {
	mut output := ''
	last := entries.len - 1
	for i, entry in entries {
		content := if i < last { '${entry.name}, ' } else { entry.name }
		output += print_cell(content, 0, .left, no_style, args)
	}
	println(output)
}

fn print_cell(s string, width int, align Align, style Style, args Args) string {
	mut output := ''
	pad := width - term.strip_ansi(s).runes().len

	if align == .right && pad > 0 {
		output += ' '.repeat(pad)
	}

	content := if args.colorize {
		style_string(s, style)
	} else {
		term.strip_ansi(s)
	}
	output += content

	if align == .left && pad > 0 {
		output += ' '.repeat(pad)
	}

	return output
}

fn print_dir_name(name string, args Args) {
	if name.len > 0 {
		print('\n')
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
