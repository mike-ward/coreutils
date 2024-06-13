module main

import common
import flag

const app_name = 'ls'
const current_dir = ['.']

struct Args {
	// display options
	long_format   bool
	list_by_lines bool
	one_per_line  bool
	dir_indicator bool
	with_commas   bool
	colorize      bool
	width_in_cols int
	page_output   bool
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
	recursive    bool
	//
	// long view options
	inode          bool
	size_ki        bool
	size_kb        bool
	no_header      bool
	no_permissions bool
	no_hard_links  bool
	no_owner_name  bool
	no_group_name  bool
	no_size        bool
	no_date        bool
	link_origin    bool
	//
	// from ls colors
	style_di Style
	style_fi Style
	style_ln Style
	style_ex Style
	//
	// file arguments
	files []string
}

fn parse_args(args []string) Args {
	mut fp := flag.new_flag_parser(args)

	fp.application(app_name)
	fp.version(common.coreutils_version())
	fp.skip_executable()
	fp.description('List information about FILES (current directory by default)')
	fp.arguments_description('[FILES]')

	// eol := common.eol()
	// wrap := eol + flag.space

	all := fp.bool('', `a`, false, 'do not ignore entries starting with .')
	colorize := fp.bool('', `c`, false, 'color the listing')
	only_dirs := fp.bool('', `d`, false, 'list only directories')
	dirs_first := fp.bool('', `g`, false, 'group directories before files')
	size_ki := fp.bool('', `k`, false, 'sizes in kibibytes (1024) (e.g. 1k 234m 2g)')
	size_kb := fp.bool('', `K`, false, 'sizes in Kilobytes (1000) (e.g. 1kb 234mb 2gb)')
	long_format := fp.bool('', `l`, false, 'long listing format')
	with_commas := fp.bool('', `m`, false, 'comma separated list of entries')
	page_output := fp.bool('', `p`, false, 'page list screen at a time')

	sort_reverse := fp.bool('', `r`, false, 'reverse the listing order')
	sort_size := fp.bool('', `s`, false, 'sort by file size, largest first')
	sort_time := fp.bool('', `t`, false, 'sort by time, newest firsts')
	sort_width := fp.bool('', `w`, false, 'sort by width, shortest first')
	sort_ext := fp.bool('', `x`, false, 'sort by entry extension')
	sort_none := fp.bool('', `y`, false, 'do not sort')

	dir_indicator := fp.bool('', `D`, false, 'append / to directories')
	link_origin := fp.bool('', `L`, false, "list link's origin information")
	recursive := fp.bool('', `R`, false, 'list subdirectories recursively')
	list_by_lines := fp.bool('', `X`, false, 'list entries by lines instead of by columns')
	one_per_line := fp.bool('', `1`, false, 'list one file per line')

	width_in_cols := fp.int('width', ` `, 0, 'set output width to <int>. 0 means no limit')
	no_header := fp.bool('header', ` `, false, 'hide header row')
	no_permissions := fp.bool('permissions', ` `, false, 'hide permissions')
	no_hard_links := fp.bool('hard-links', ` `, false, 'hide hard links count')
	no_owner_name := fp.bool('owner', ` `, false, 'hide owner name')
	no_group_name := fp.bool('group', ` `, false, 'hide group name')
	no_size := fp.bool('size', ` `, false, 'hide file size')
	no_date := fp.bool('date', ` `, false, 'hide date')
	inode := fp.bool('inode', ` `, false, 'show inodes')

	fp.footer('

		The -c option emits color codes only when standard output is
		connected to a terminal. Colors are defined by the LS_COLORS 
		environment variable. To set colors, use the dircolors command.'.trim_indent())

	fp.footer(common.coreutils_footer())
	files := fp.finalize() or { exit_error(err.msg()) }
	style_map := make_style_map()

	return Args{
		all: all
		dirs_first: dirs_first
		only_dirs: only_dirs
		list_by_lines: list_by_lines
		long_format: long_format
		one_per_line: one_per_line
		page_output: page_output
		with_commas: with_commas
		colorize: colorize
		width_in_cols: width_in_cols
		dir_indicator: dir_indicator
		sort_reverse: sort_reverse
		sort_size: sort_size
		sort_time: sort_time
		sort_width: sort_width
		sort_ext: sort_ext
		sort_none: sort_none
		recursive: recursive
		size_ki: size_ki
		size_kb: size_kb
		link_origin: link_origin
		no_header: no_header
		inode: inode
		no_permissions: no_permissions
		no_hard_links: no_hard_links
		no_owner_name: no_owner_name
		no_group_name: no_group_name
		no_size: no_size
		no_date: no_date
		files: if files.len == 0 { current_dir } else { files }
		style_di: style_map['di']
		style_fi: style_map['fi']
		style_ln: style_map['ln']
		style_ex: style_map['ex']
	}
}

@[noreturn]
fn exit_error(msg string) {
	common.exit_with_error_message(app_name, msg)
}
