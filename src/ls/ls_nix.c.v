#include <pwd.h>
#include <grp.h>

struct Passwd {
	pw_name  &char
	pw_uid   u32
	pw_gid   u32
	pw_dir   &char
	pw_shell &char
}

struct Group {
	gr_name &char
	gr_gid  u32
	gr_mem  &&char
}

fn C.getpwuid(uid u32) &Passwd
fn C.getgrgid(uid u32) &Group

fn get_owner_name(uid u32) string {
	p := C.getpwuid(uid)
	return unsafe { cstring_to_vstring(p.pw_name) }
}

fn get_group_name(uid u32) string {
	grp := C.getgrgid(uid)
	return unsafe { cstring_to_vstring(grp.gr_name) }
}
