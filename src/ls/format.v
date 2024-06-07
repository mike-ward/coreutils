import term
import v.mathutil

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
		else { format_by_columns(entries, args) }
	}
}

fn format_long_listing(entries []Entry, args Args) []Row {
	return []Row{}
}

fn format_by_columns(entries []Entry, args Args) []Row {
	len := entries.max_name_len() + column_spacing
	width, _ := term.get_terminal_size()
	max_cols := width / len
	max_rows := entries.len / max_cols
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
	max_cols := width / len
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
	print(' '.repeat(pad))
}

fn (entries []Entry) max_name_len() int {
	mut max := 0
	for entry in entries {
		max = mathutil.max(entry.name.len, max)
	}
	return max
}
