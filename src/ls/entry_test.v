module main

fn test_readable_size() {
	assert readable_size(395, false) == '395'
	assert readable_size(395, true) == '395'

	assert readable_size(200_000, false) == '195.4K'
	assert readable_size(200_000, true) == '200.0KB'

	assert readable_size(100_000_000, false) == '95.4M'
	assert readable_size(100_000_000, true) == '100.0MB'

	assert readable_size(100_000_000_000, false) == '93.2G'
	assert readable_size(100_000_000_000, true) == '100.0GB'

	assert readable_size(100_000_000_000_000, false) == '91.0T'
	assert readable_size(100_000_000_000_000, true) == '100.0TB'

	assert readable_size(100_000_000_000_000_000, false) == '88.9P'
	assert readable_size(100_000_000_000_000_000, true) == '100.0PB'

	assert readable_size(8_000_000_000_000_000_000, false) == '7.0E'
	assert readable_size(8_000_000_000_000_000_000, true) == '8.0EB'
}
