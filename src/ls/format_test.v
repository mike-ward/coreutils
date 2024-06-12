module main

const term_width = 195

const test_entries = [
	Entry{
		name: '1.v'
	},
	Entry{
		name: '2.v'
	},
	Entry{
		name: '3.v'
	},
	Entry{
		name: '1.v'
	},
	Entry{
		name: '2.v'
	},
	Entry{
		name: '3.v'
	},
	Entry{
		name: '4.v'
	},
	Entry{
		name: '5.v'
	},
	Entry{
		name: '6.v'
	},
	Entry{
		name: '7.v'
	},
	Entry{
		name: '8.v'
	},
	Entry{
		name: '9.v'
	},
	Entry{
		name: '10.v'
	},
	Entry{
		name: '11.v'
	},
	Entry{
		name: '12.v'
	},
	Entry{
		name: '13.v'
	},
	Entry{
		name: '14.v'
	},
	Entry{
		name: '15.v'
	},
	Entry{
		name: '16.v'
	},
	Entry{
		name: '17.v'
	},
]

fn test_by_cell() {
	assert format_by_cells(test_entries, term_width, Args{}) == [
		Row{
			cells: [Cell{
				content: '1.v'
				width: 7
			}, Cell{
				content: '3.v'
				width: 7
			}, Cell{
				content: '2.v'
				width: 7
			}, Cell{
				content: '4.v'
				width: 7
			}, Cell{
				content: '6.v'
				width: 7
			}, Cell{
				content: '8.v'
				width: 7
			}, Cell{
				content: '10.v'
				width: 7
			}, Cell{
				content: '12.v'
				width: 7
			}, Cell{
				content: '14.v'
				width: 7
			}, Cell{
				content: '16.v'
				width: 7
			}]
		},
		Row{
			cells: [Cell{
				content: '2.v'
				width: 7
			}, Cell{
				content: '1.v'
				width: 7
			}, Cell{
				content: '3.v'
				width: 7
			}, Cell{
				content: '5.v'
				width: 7
			}, Cell{
				content: '7.v'
				width: 7
			}, Cell{
				content: '9.v'
				width: 7
			}, Cell{
				content: '11.v'
				width: 7
			}, Cell{
				content: '13.v'
				width: 7
			}, Cell{
				content: '15.v'
				width: 7
			}, Cell{
				content: '17.v'
				width: 7
			}]
		},
	]
}

fn test_format_by_lines() {
	assert format_by_lines(test_entries, term_width, Args{}) == [
		Row{
			cells: [Cell{
				content: '1.v'
				width: 7
			}, Cell{
				content: '2.v'
				width: 7
			}, Cell{
				content: '3.v'
				width: 7
			}, Cell{
				content: '1.v'
				width: 7
			}, Cell{
				content: '2.v'
				width: 7
			}, Cell{
				content: '3.v'
				width: 7
			}, Cell{
				content: '4.v'
				width: 7
			}, Cell{
				content: '5.v'
				width: 7
			}, Cell{
				content: '6.v'
				width: 7
			}, Cell{
				content: '7.v'
				width: 7
			}, Cell{
				content: '8.v'
				width: 7
			}, Cell{
				content: '9.v'
				width: 7
			}]
		},
		Row{
			cells: [Cell{
				content: '10.v'
				width: 7
			}, Cell{
				content: '11.v'
				width: 7
			}, Cell{
				content: '12.v'
				width: 7
			}, Cell{
				content: '13.v'
				width: 7
			}, Cell{
				content: '14.v'
				width: 7
			}, Cell{
				content: '15.v'
				width: 7
			}, Cell{
				content: '16.v'
				width: 7
			}, Cell{
				content: '17.v'
				width: 7
			}]
		},
	]
}

fn test_with_commas() {
	assert format_with_commas(test_entries, Args{}) == [
		Row{
			cells: [Cell{
				content: '1.v, '
				width: 0
			}, Cell{
				content: '2.v, '
				width: 0
			}, Cell{
				content: '3.v, '
				width: 0
			}, Cell{
				content: '1.v, '
				width: 0
			}, Cell{
				content: '2.v, '
				width: 0
			}, Cell{
				content: '3.v, '
				width: 0
			}, Cell{
				content: '4.v, '
				width: 0
			}, Cell{
				content: '5.v, '
				width: 0
			}, Cell{
				content: '6.v, '
				width: 0
			}, Cell{
				content: '7.v, '
				width: 0
			}, Cell{
				content: '8.v, '
				width: 0
			}, Cell{
				content: '9.v, '
				width: 0
			}, Cell{
				content: '10.v, '
				width: 0
			}, Cell{
				content: '11.v, '
				width: 0
			}, Cell{
				content: '12.v, '
				width: 0
			}, Cell{
				content: '13.v, '
				width: 0
			}, Cell{
				content: '14.v, '
				width: 0
			}, Cell{
				content: '15.v, '
				width: 0
			}, Cell{
				content: '16.v, '
				width: 0
			}, Cell{
				content: '17.v'
				width: 0
			}]
		},
	]
}

fn test_format_one_per_line() {
	assert format_one_per_line(test_entries, Args{}) == [
		Row{
			cells: [Cell{
				content: '1.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '2.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '3.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '1.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '2.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '3.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '4.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '5.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '6.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '7.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '8.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '9.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '10.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '11.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '12.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '13.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '14.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '15.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '16.v'
				width: 0
			}]
		},
		Row{
			cells: [Cell{
				content: '17.v'
				width: 0
			}]
		},
	]
}
