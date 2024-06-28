module main

import os

const test_a = os.temp_dir() + '/test_a.txt'
const test_b = os.temp_dir() + '/test_b.txt'

fn testsuite_begin() {
	create_test_data()
}

fn create_test_data() {
	os.write_lines(test_a, [
		'Now is the time',
		'for all good men',
		'to come to the aid',
		'of their country',
	]) or {}

	os.write_lines(test_b, [
		' Now is the time',
		'   for all good men',
		'      to come to the aid',
		'        of their country',
	]) or {}
}

fn test_no_options() {
	options := Options{
		files: [test_a]
	}
	assert sort(options) == [
		'Now is the time',
		'for all good men',
		'of their country',
		'to come to the aid',
	]
}

fn test_ignore_case() {
	options := Options{
		ignore_case: true
		files: [test_a]
	}
	assert sort(options) == [
		'for all good men',
		'Now is the time',
		'of their country',
		'to come to the aid',
	]
}

fn test_ignore_leading_blanks() {
	options := Options{
		ignore_leading_blanks: true
		files: [test_b]
	}
	assert sort(options) == [
		' Now is the time',
		'   for all good men',
		'        of their country',
		'      to come to the aid',
	]
}
