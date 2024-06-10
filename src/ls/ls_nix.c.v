#include <pwd.h>
#include <grp.h>
#include <unistd.h>

struct Passwd {
	pw_name  &char
	pw_uid   usize
	pw_gid   usize
	pw_dir   &char
	pw_shell &char
}

struct Group {
	gr_name &char
	gr_gid  usize
	gr_mem  &&char
}

fn C.getpwuid(uid usize) &Passwd
fn C.getgrgid(uid usize) &Group

fn get_owner_name(uid usize) string {
	p := C.getpwuid(uid)
	return unsafe { cstring_to_vstring(p.pw_name) }
}

fn get_group_name(uid usize) string {
	grp := C.getgrgid(uid)
	return unsafe { cstring_to_vstring(grp.gr_name) }
}

fn C.readlink(file &char, buf &char, buf_size usize)

fn read_link(file string) string {
	buf_size := 2048
	buf := '\0'.repeat(buf_size)
	C.readlink(file.str, buf.str, usize(buf_size))
	return buf
}
