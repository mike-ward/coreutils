module main

import common
import flag

const app_name = 'ls'

struct Args {
	all              bool
	almost_all       bool
	group_dirs_first bool
	list_by_lines    bool
	long_format      bool
	reverse          bool
	one_per_line     bool
	with_commas      bool
	files            []string
}

fn parse_args(args []string) Args {
	mut fp := flag.new_flag_parser(args)

	fp.application(app_name)
	fp.version(common.coreutils_version())
	fp.skip_executable()
	fp.description('
	List information about the FILEs (the current directory by default).
	Sort entries alphabetically if none of -cftuvSUX nor --sort is specified.'.trim_indent())

	eol := common.eol()
	wrap := eol + flag.space

	all := fp.bool('all', `a`, false, 'do not ignore entries starting with .')
	almost_all := fp.bool('almost-all', `A`, false, 'do not list implied . and ..')
	group_dirs_first := fp.bool('group-directories-first', ` `, false,
		'group directories before files;${wrap}' +
		'can be augmented with a --sort option, but any${wrap}' +
		'use of --sort=none (-U) disables grouping')
	long_format := fp.bool('', `l`, false, 'use long listing format')
	with_commas := fp.bool('', `m`, false, 'fill width with a comma separated list of entries')
	reverse := fp.bool('reverse', `r`, false, 'reverse order while sorting')
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

	return Args{
		all: all
		almost_all: almost_all
		group_dirs_first: group_dirs_first
		list_by_lines: list_by_lines
		long_format: long_format
		reverse: reverse
		one_per_line: one_per_line
		with_commas: with_commas
		files: if files.len == 0 { ['.'] } else { files }
	}
}

@[noreturn]
fn exit_error(msg string) {
	common.exit_with_error_message(app_name, msg)
}
