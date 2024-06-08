module main

fn test_readable_size() {
	assert readable_size(395, false) == '395'
	assert readable_size(395, true) == '395'

	assert readable_size(200_000, false) == '195.4K'
	assert readable_size(200_000, true) == '200KB'

	assert readable_size(100_000_000, false) == '95.4M'
	assert readable_size(100_000_000, true) == '100MB'

	assert readable_size(100_000_000_000, false) == '93.2G'
	assert readable_size(100_000_000_000, true) == '100GB'

	assert readable_size(100_000_000_000_000, false) == '91T'
	assert readable_size(100_000_000_000_000, true) == '100TB'

	assert readable_size(100_000_000_000_000_000, false) == '88.9P'
	assert readable_size(100_000_000_000_000_000, true) == '100PB'

	assert readable_size(8_000_000_000_000_000_000, false) == '7E'
	assert readable_size(8_000_000_000_000_000_000, true) == '8EB'
}
