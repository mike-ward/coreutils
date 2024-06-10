import term
import os

struct Term_Color {
	bold bool
	ul   bool
	fg   fn (string) string = no_color
	bg   fn (string) string = no_color
}

fn color_string(s string, term_color Term_Color) string {
	mut out := term_color.fg(s)
	out = term_color.bg(out)

	if term_color.bold {
		out = term.bold(out)
	}
	if term_color.ul {
		out = term.underline(out)
	}

	return out
}

fn get_ls_colors() map[string]Term_Color {
	mut color_map := map[string]Term_Color{}

	nothing := Term_Color{
		bold: false
		ul: false
		fg: no_color
		bg: no_color
	}

	color_map['di'] = nothing
	color_map['fi'] = nothing
	color_map['ln'] = nothing
	color_map['ex'] = nothing

	ls_colors := os.getenv('LS_COLORS')
	fields := ls_colors.split(':')

	for field in fields {
		colors := field.split('=')
		if colors.len == 2 {
			id := colors[0]
			term_color := make_term_color(colors[1])
			color_map[id] = term_color
		}
	}
	return color_map
}

fn make_term_color(ansi string) Term_Color {
	mut bold := false
	mut ul := false
	mut fg := no_color
	mut bg := no_color

	codes := ansi.split(';')

	for code in codes {
		match code {
			'0' { bold = false }
			'1' { bold = true }
			'4' { ul = true }
			'31' { fg = term.red }
			'32' { fg = term.green }
			'34' { fg = term.blue }
			'35' { fg = term.magenta }
			'36' { fg = term.cyan }
			'37' { fg = term.gray }
			'40' { bg = term.bg_black }
			'41' { bg = term.bg_red }
			'42' { bg = term.bg_green }
			'44' { bg = term.bg_blue }
			'46' { bg = term.bg_cyan }
			'91' { fg = term.bright_red }
			'92' { fg = term.bright_green }
			'93' { fg = term.yellow }
			'94' { fg = term.bright_blue }
			'96' { fg = term.magenta }
			'101' { bg = term.bright_bg_red }
			'102' { bg = term.bright_bg_green }
			'103' { bg = term.bg_yellow }
			'104' { bg = term.bright_bg_blue }
			'106' { bg = term.bright_bg_magenta }
			else {}
		}
	}

	return Term_Color{
		bold: bold
		ul: ul
		fg: fg
		bg: bg
	}
}

fn no_color(s string) string {
	return s
}

