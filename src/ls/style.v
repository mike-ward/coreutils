import term
import os

struct Style {
	fg   fn (string) string = no_color
	bg   fn (string) string = no_color
	bold bool
	dim  bool
	ul   bool
}

const no_style = Style{}

const dim_style = Style{
	dim: true
}

const di_style = Style{
	bold: true
	fg: fgg('36') // cyan
}

const fi_style = Style{
	fg: fgg('32') // green
}

const ln_style = Style{
	bold: true
	fg: fgg('34') // magenta
}

const ex_style = Style{
	bold: true
	fg: fgg('31') // red
}

const so_style = Style{
	fg: fgg('32') // green
}

const pi_style = Style{
	fg: fgg('33') // orange
}

const bd_style = Style{
	fg: fgg('34')
	bg: bgg('46')
}

const cd_style = Style{
	fg: fgg('34')
	bg: bgg('43')
}

fn style_string(s string, style Style) string {
	if !term.can_show_color_on_stdout() {
		return s
	}
	mut out := style.fg(s)
	out = style.bg(out)
	out = if style.bold { term.bold(out) } else { out }
	out = if style.ul { term.underline(out) } else { out }
	out = if style.dim { term.dim(out) } else { out }
	return out
}

fn make_style_map() map[string]Style {
	mut style_map := map[string]Style{}

	// start with some defaults
	style_map['di'] = di_style
	style_map['fi'] = fi_style
	style_map['ln'] = ln_style
	style_map['ex'] = ex_style
	style_map['so'] = so_style
	style_map['pi'] = pi_style
	style_map['bd'] = bd_style
	style_map['cd'] = cd_style

	// example LS_COLORS
	// di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43
	ls_colors := os.getenv('LS_COLORS')
	fields := ls_colors.split(':')

	for field in fields {
		id_codes := field.split('=')
		if id_codes.len == 2 {
			id := id_codes[0]
			style := make_style(id_codes[1])
			style_map[id] = style
		}
	}
	return style_map
}

fn make_style(ansi string) Style {
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
		fg: fg
		bg: bg
		bold: bold
		ul: ul
	}
}

fn no_color(s string) string {
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
