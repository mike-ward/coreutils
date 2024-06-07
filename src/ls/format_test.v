module main

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

fn test_by_column() {
	assert format_by_columns(test_entries, Args{}) == [
		Row{
			columns: [Column{
				name: '1.v'
				width: 7
			}, Column{
				name: '3.v'
				width: 7
			}, Column{
				name: '2.v'
				width: 7
			}, Column{
				name: '4.v'
				width: 7
			}, Column{
				name: '6.v'
				width: 7
			}, Column{
				name: '8.v'
				width: 7
			}, Column{
				name: '10.v'
				width: 7
			}, Column{
				name: '12.v'
				width: 7
			}, Column{
				name: '14.v'
				width: 7
			}, Column{
				name: '16.v'
				width: 7
			}]
		},
		Row{
			columns: [Column{
				name: '2.v'
				width: 7
			}, Column{
				name: '1.v'
				width: 7
			}, Column{
				name: '3.v'
				width: 7
			}, Column{
				name: '5.v'
				width: 7
			}, Column{
				name: '7.v'
				width: 7
			}, Column{
				name: '9.v'
				width: 7
			}, Column{
				name: '11.v'
				width: 7
			}, Column{
				name: '13.v'
				width: 7
			}, Column{
				name: '15.v'
				width: 7
			}, Column{
				name: '17.v'
				width: 7
			}]
		},
	]
}

fn test_format_by_lines() {
	assert format_by_lines(test_entries, Args{ list_by_lines: true }) == [
		Row{
			columns: [Column{
				name: '1.v'
				width: 7
			}, Column{
				name: '2.v'
				width: 7
			}, Column{
				name: '3.v'
				width: 7
			}, Column{
				name: '1.v'
				width: 7
			}, Column{
				name: '2.v'
				width: 7
			}, Column{
				name: '3.v'
				width: 7
			}, Column{
				name: '4.v'
				width: 7
			}, Column{
				name: '5.v'
				width: 7
			}, Column{
				name: '6.v'
				width: 7
			}, Column{
				name: '7.v'
				width: 7
			}, Column{
				name: '8.v'
				width: 7
			}, Column{
				name: '9.v'
				width: 7
			}]
		},
		Row{
			columns: [Column{
				name: '10.v'
				width: 7
			}, Column{
				name: '11.v'
				width: 7
			}, Column{
				name: '12.v'
				width: 7
			}, Column{
				name: '13.v'
				width: 7
			}, Column{
				name: '14.v'
				width: 7
			}, Column{
				name: '15.v'
				width: 7
			}, Column{
				name: '16.v'
				width: 7
			}, Column{
				name: '17.v'
				width: 7
			}]
		},
	]
}

fn test_with_commas() {
	assert format_with_commas(test_entries, Args{}) == [
		Row{
			columns: [Column{
				name: '1.v, '
				width: 0
			}, Column{
				name: '2.v, '
				width: 0
			}, Column{
				name: '3.v, '
				width: 0
			}, Column{
				name: '1.v, '
				width: 0
			}, Column{
				name: '2.v, '
				width: 0
			}, Column{
				name: '3.v, '
				width: 0
			}, Column{
				name: '4.v, '
				width: 0
			}, Column{
				name: '5.v, '
				width: 0
			}, Column{
				name: '6.v, '
				width: 0
			}, Column{
				name: '7.v, '
				width: 0
			}, Column{
				name: '8.v, '
				width: 0
			}, Column{
				name: '9.v, '
				width: 0
			}, Column{
				name: '10.v, '
				width: 0
			}, Column{
				name: '11.v, '
				width: 0
			}, Column{
				name: '12.v, '
				width: 0
			}, Column{
				name: '13.v, '
				width: 0
			}, Column{
				name: '14.v, '
				width: 0
			}, Column{
				name: '15.v, '
				width: 0
			}, Column{
				name: '16.v, '
				width: 0
			}, Column{
				name: '17.v'
				width: 0
			}]
		},
	]
}

fn test_format_one_per_line() {
	assert format_one_per_line(test_entries, Args{}) == [
		Row{
			columns: [Column{
				name: '1.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '2.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '3.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '1.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '2.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '3.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '4.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '5.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '6.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '7.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '8.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '9.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '10.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '11.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '12.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '13.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '14.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '15.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '16.v'
				width: 0
			}]
		},
		Row{
			columns: [Column{
				name: '17.v'
				width: 0
			}]
		},
	]
}
