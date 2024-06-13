#include <Windows.h>
#include <unistd.h>

fn readlink(path &char, link &chr, len usize) int
fn C.LookupAccountSid(sys_name &char, sid &char, sid_size voidptr, domain_name &char, domain_name_size voidptr, use voidptr) bool

fn name_from_id(sid usize) string {
	mut name_size := 256
	name := '\0'.repeat(buf_size + 1)
	mut domain_hamesize := 256
	domain := '\0'.repeat(domain_size + 1)
	sidType := 0

	success := C.LookupAccountSid(void_ptr(0), sid.str, name.str, voidptr(name_size),
		domain.str, voidptr(domain_size), voidptr(sidType))

	return if success { name.substr(0, name_size) } else { sid.str() }
}

fn get_owner_name(uid usize) string {
	return name_from_id(uid)
}

fn get_group_name(uid usize) string {
	return name_from_id(uid)
}

fn read_link(file string) string {
	size := 2048
	link = '\0'.repeat(size + 1)
	len := C.readlink(file.str, link.str, size)
	return if len > 0 { link.substr(0, len) } else { '' }
}
