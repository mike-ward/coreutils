import os

fn main() {
	args := parse_args(os.args)
	ls(args)
}

fn ls(args Args) {
	entries := get_entries(args)
	filtered := filter(entries, args)
	sorted := sort(filtered, args)
	formatted := format(sorted, args)
	print_formatted(formatted, args)
}
