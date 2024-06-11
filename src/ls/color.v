import term
import os

struct Style {
	bold bool
	ul   bool
	fg   fn (string) string = color_none
	bg   fn (string) string = color_none
}

const empty_style = Style{
	bold: false
	ul: false
	fg: color_none
	bg: color_none
}

fn colorize_string(s string, style Style) string {
	if !term.can_show_color_on_stdout() {
		return s
	}
	mut out := style.fg(s)
	out = style.bg(out)
	out = if style.bold { term.bold(out) } else { out }
	out = if style.ul { term.underline(out) } else { out }
	return out
}

fn get_ls_colors() map[string]Style {
	mut color_map := map[string]Style{}
	color_map['di'] = empty_style
	color_map['fi'] = empty_style
	color_map['ln'] = empty_style
	color_map['ex'] = empty_style

	// example LS_COLORS
	// di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43
	ls_colors := os.getenv('LS_COLORS')
	fields := ls_colors.split(':')

	for field in fields {
		colors := field.split('=')
		if colors.len == 2 {
			id := colors[0]
			style := make_style(colors[1])
			color_map[id] = style
		}
	}
	return color_map
}

fn make_style(ansi string) Style {
	mut bold := false
	mut ul := false
	mut fg := color_none
	mut bg := color_none

	codes := ansi.split(';')

	for code in codes {
		match code {
			'0' { bold = false }
			'1' { bold = true }
			'4' { ul = true }
			'31' { fg = fgg(code) }
			'32' { fg = fgg(code) }
			'33' { fg = fgg(code) }
			'34' { fg = fgg(code) }
			'35' { fg = fgg(code) }
			'36' { fg = fgg(code) }
			'37' { fg = fgg(code) }
			'40' { bg = bgg(code) }
			'41' { bg = bgg(code) }
			'42' { bg = bgg(code) }
			'43' { bg = bgg(code) }
			'44' { bg = bgg(code) }
			'45' { bg = bgg(code) }
			'46' { bg = bgg(code) }
			'47' { bg = bgg(code) }
			'90' { fg = fgg(code) }
			'91' { fg = fgg(code) }
			'92' { fg = fgg(code) }
			'93' { fg = fgg(code) }
			'94' { fg = fgg(code) }
			'95' { fg = fgg(code) }
			'96' { fg = fgg(code) }
			'100' { bg = bgg(code) }
			'101' { bg = bgg(code) }
			'102' { bg = bgg(code) }
			'103' { bg = bgg(code) }
			'104' { bg = bgg(code) }
			'105' { bg = bgg(code) }
			'106' { bg = bgg(code) }
			else {}
		}
	}

	return Style{
		bold: bold
		ul: ul
		fg: fg
		bg: bg
	}
}

fn color_none(s string) string {
	return s
}

fn fgg(cc string) fn (string) string {
	return fn [cc] (msg string) string {
		return term.format(msg, cc, '39')
	}
}

fn bgg(cc string) fn (string) string {
	return fn [cc] (msg string) string {
		return term.format(msg, cc, '49')
	}
}
