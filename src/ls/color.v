import term
import os

struct Term_Color {
	bold bool
	ul   bool
	fg   fn (string) string = empty_color
	bg   fn (string) string = empty_color
}

const empty_term_color = Term_Color{
	bold: false
	ul: false
	fg: empty_color
	bg: empty_color
}

fn color_string(s string, term_color Term_Color) string {
	mut out := term_color.fg(s)
	out = term_color.bg(out)
	out = if term_color.bold { term.bold(out) } else { out }
	out = if term_color.ul { term.underline(out) } else { out }
	return out
}

fn get_ls_colors() map[string]Term_Color {
	mut color_map := map[string]Term_Color{}
	color_map['di'] = empty_term_color
	color_map['fi'] = empty_term_color
	color_map['ln'] = empty_term_color
	color_map['ex'] = empty_term_color

	// example LS_COLORS
	// di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43
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
	mut fg := empty_color
	mut bg := empty_color

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

fn empty_color(s string) string {
	return s
}
