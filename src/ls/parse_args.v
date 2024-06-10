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
	// filtering and sorting option
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
	no_permissions bool
	human_readable bool

	files []string
	// ls colors
	ls_color_di Term_Color
	ls_color_fi Term_Color
	ls_color_ln Term_Color
	ls_color_ex Term_Color
}

fn parse_args(args []string) Args {
	mut fp := flag.new_flag_parser(args)

	fp.application(app_name)
	fp.version(common.coreutils_version())
	fp.skip_executable()
	fp.description('List information about the FILEs (the current directory by default).')

	eol := common.eol()
	wrap := eol + flag.space

	all := fp.bool('all', `a`, false, 'do not ignore entries starting with .')
	list_by_cols := fp.bool('', `C`, true, 'list entries by columns')
	colorize := fp.bool('color', ` `, false, 'color the output')
	only_dirs := fp.bool('only-dirs', `D`, false, 'list only directories')
	dirs_first := fp.bool('group-directories-first', ` `, false,
		'group directories before files;${wrap}' +
		'can be augmented with a --sort option, but any${wrap}' +
		'use of --sort=none (-U) disables grouping')
	human_readable := fp.bool('human-readable', `h`, false, 'with -l and -s, print sizes like 1K 234M 2G etc.')
	long_format := fp.bool('', `l`, false, 'use long listing format')
	with_commas := fp.bool('', `m`, false, 'fill width with a comma separated list of entries')
	dir_indicator := fp.bool('dir-indicator', `p`, false, 'append / indicator to directories')
	sort_reverse := fp.bool('reverse', `r`, false, 'reverse order while sorting')
	sort_size := fp.bool('', `S`, false, 'sort by file size, largest first')
	sort_time := fp.bool('', `t`, false, 'sort by time, newest first; see --time')
	sort_width := fp.bool('', `W`, false, 'sort by width, shortest first')
	sort_ext := fp.bool('', `X`, false, 'sort by entry extension')
	list_by_lines := fp.bool('', `x`, false, 'list entries by lines instead of by columns')
	one_per_line := fp.bool('', `1`, false, 'list one file per line')

	fp.footer("

		The SIZE argument is an integer and optional unit (example: 10K is 10*1024).
		Units are K,M,G,T,P,E,Z,Y,R,Q (powers of 1024) or KB,MB,... (powers of 1000).
		Binary prefixes can be used, too: KiB=K, MiB=M, and so on.

		The TIME_STYLE argument can be full-iso, long-iso, iso, locale, or +FORMAT.
		FORMAT is interpreted like in date(1).  If FORMAT is FORMAT1<newline>FORMAT2,
		then FORMAT1 applies to non-recent files and FORMAT2 to recent files.
		TIME_STYLE prefixed with 'posix-' takes effect only outside the POSIX locale.
		Also the TIME_STYLE environment variable sets the default style to use.

		The WHEN argument defaults to 'always' and can also be 'auto' or 'never'.

		Using color to distinguish file types is disabled both by default and
		with --color=never.  With --color=auto, ls emits color codes only when
		standard output is connected to a terminal.  The LS_COLORS environment
		variable can change the settings.  Use the dircolors(1) command to set it.

		Exit status:
		 0  if OK,
		 1  if minor problems (e.g., cannot access subdirectory),
		 2  if serious trouble (e.g., cannot access command-line argument).".trim_indent())

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
