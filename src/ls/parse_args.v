module main

import common
import flag

const app_name = 'ls'

struct Args {
	// display options
	long_format   bool
	list_by_lines bool
	one_per_line  bool
	dir_indicator bool
	with_commas   bool
	colorize      bool
	//
	// filter, group and sorting options
	all          bool
	dirs_first   bool
	only_dirs    bool
	sort_none    bool
	sort_size    bool
	sort_time    bool
	sort_natural bool
	sort_ext     bool
	sort_width   bool
	sort_reverse bool
	//
	// long view options
	inode          bool
	no_permissions bool
	human_readable bool
	//
	// ls colors
	ls_color_di Term_Color
	ls_color_fi Term_Color
	ls_color_ln Term_Color
	ls_color_ex Term_Color
	//
	// file arguments
	files []string
}

fn parse_args(args []string) Args {
	mut fp := flag.new_flag_parser(args)

	fp.application(app_name)
	fp.version(common.coreutils_version())
	fp.skip_executable()
	fp.description('List information about the files. (current directory by default)')
	fp.arguments_description('[FILES]')

	// eol := common.eol()
	// wrap := eol + flag.space

	all := fp.bool('', `a`, false, 'do not ignore entries starting with .')
	colorize := fp.bool('', `c`, false, 'color the listing')
	only_dirs := fp.bool('', `d`, false, 'list only directories')
	dirs_first := fp.bool('', `g`, false, 'group directories before files')
	inode := fp.bool('', `i`, false, 'show inode of each file')
	human_readable := fp.bool('', `k`, false, 'friendly file sizes (e.g. 1K 234M 2G)')
	long_format := fp.bool('', `l`, false, 'use long listing format')
	with_commas := fp.bool('', `m`, false, 'comma separated list of entries')
	dir_indicator := fp.bool('', `p`, false, 'append / to directories')
	sort_reverse := fp.bool('', `r`, false, 'reverse the listing order')
	sort_size := fp.bool('', `s`, false, 'sort by file size, largest first')
	sort_time := fp.bool('', `t`, false, 'sort by time, newest firsts')
	sort_width := fp.bool('', `w`, false, 'sort by width, shortest first')
	sort_ext := fp.bool('', `x`, false, 'sort by entry extension')
	list_by_cols := fp.bool('', `C`, true, 'list entries by columns (default)')
	list_by_lines := fp.bool('', `L`, false, 'list entries by lines instead of by columns')
	one_per_line := fp.bool('', `1`, false, 'list one file per line')

	fp.footer('

		ls with the -c option emits color codes only when standard output is connected
		to a terminal. The LS_COLORS environment variable can change the color settings.  
		Use the dircolors command to set it.'.trim_indent())

	fp.footer(common.coreutils_footer())
	files := fp.finalize() or { exit_error(err.msg()) }
	ls_colors := get_ls_colors()

	return Args{
		all: all
		dirs_first: dirs_first
		only_dirs: only_dirs
		list_by_lines: list_by_lines || !list_by_cols
		long_format: long_format
		one_per_line: one_per_line
		with_commas: with_commas
		colorize: colorize
		dir_indicator: dir_indicator
		sort_reverse: sort_reverse
		sort_size: sort_size
		sort_time: sort_time
		sort_width: sort_width
		sort_ext: sort_ext
		inode: inode
		human_readable: human_readable
		files: files
		ls_color_di: ls_colors['di']
		ls_color_fi: ls_colors['fi']
		ls_color_ln: ls_colors['ln']
		ls_color_ex: ls_colors['ex']
	}
}

@[noreturn]
fn exit_error(msg string) {
	common.exit_with_error_message(app_name, msg)
}
