#include <Windows.h>
#include <stdio.h>

fn C.LookupAccountSid(sys_name &char, sid &char, sid_size voidptr, domain_name &char, domain_name_size voidptr, use voidptr) bool

fn name_from_id(sid usize) string {
	name_size := 256
	name := '\0'.repeat(buf_size)
	domain_hamesize := 256
	domain := '\0'.repeat(domain_size)
	sidType := 0

	if C.LookupAccountSid(void_ptr(0), sid.str, name.str, voidptr(name_size), domain.str,
		voidptr(domain_size), voidptr(sidType))
	{
		return name.substr(0, name_size).cstring_to_vstring()
	} else {
		return sid.str()
	}
}

fn get_owner_name(uid usize) string {
	return name_from_id(uid)
}

fn get_group_name(uid usize) string {
	return name_from_id(uid)
}

fn read_link(file string) string {
	return '?'
}
