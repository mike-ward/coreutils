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
	width       int
	right_align bool
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
					content: entries[idx].name
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
			content: entry.name
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
				content: entry.name
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
			content: if i < last { '${entry.name}, ' } else { entry.name }
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
	pad := c.width - c.content.len
	if c.right_align && pad > 0 {
		print(' '.repeat(pad))
	}
	print(c.content)
	if !c.right_align && pad > 0 {
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
