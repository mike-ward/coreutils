import os
import term
import v.mathutil

fn main() {
	args := parse_args(os.args)
	display(args)
}

fn display(args Args) {
	mut entries := get_files(args)
	filter(mut entries, args)
	sort(mut entries, args)
	listings := arrange(entries, args)
	print_entries(listings, args)
}

struct Entry {
	name   string
	is_dir bool
}

fn get_files(arg Args) []Entry {
	paths := os.ls('..') or { [] }
	entries := paths.map(Entry{
		name: it
		is_dir: os.is_dir(os.join_path(os.getwd(), it))
	})
	return entries
}

fn filter(mut entries []Entry, args Args) {
}

fn sort(mut entries []Entry, args Args) {
	entries.sort_with_compare(fn (a &Entry, b &Entry) int {
		return compare_strings(a.name, b.name)
	})
}

struct Row {
mut:
	columns []Column
}

struct Column {
	name  string
	width int
}

fn arrange(entries []Entry, args Args) []Row {
	return match args.list_by_lines {
		true { arrange_by_lines(entries, args) }
		else { arrange_by_columns(entries, args) }
	}
}

fn arrange_by_columns(entries []Entry, args Args) []Row {
	len := entries.max_name_len() + 3
	width, _ := term.get_terminal_size()
	max_cols := width / len
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

fn arrange_by_lines(entries []Entry, args Args) []Row {
	len := entries.max_name_len() + 3
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

fn print_entries(rows []Row, args Args) {
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
