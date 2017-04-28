setup() {
	temp="$(mktemp -d)"
	cd $temp
	mkdir dir1
	touch dir1/file1.sh
	cp dir1/file1.sh dir1/file1.c
	cp dir1/file1.sh dir1/file1
	cp dir1/file1.sh file1.js
}

@test "Basic files" {
	run files

	[ "${lines[0]}" = "48 total" ]
	[ "${lines[1]}" = "17 file1.js" ]
	[ "${lines[2]}" = "16 dir1/file1.c" ]
	[ "${lines[3]}" = "15 dir1/file1.sh" ]
}

@test "Files in another dir" {
	run files -d dir1	

	[ "${lines[0]}" = "31 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ]
}

@test "Files with depth" {
	run files -m 1
	[ $output = "17 file1.js" ]

	run files -m 0
	[ $status != 0 ]
}

@test "All files" {
	run files -a

	[ "${lines[0]}" = "63 total" ]
	[ "${lines[1]}" = "17 file1.js" ]
	[ "${lines[2]}" = "16 dir1/file1.c" ]
	[ "${lines[3]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[3]}" = "15 dir1/file1" ]
	[ "${lines[4]}" = "15 dir1/file1" ] ||\
	[ "${lines[4]}" = "15 dir1/file1.sh" ] 
}

@test "All files with depth" {
	run files -a -m 1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[2]}" = "15 dir1/file1" ]
	[ "${lines[3]}" = "15 dir1/file1" ] ||\
	[ "${lines[3]}" = "15 dir1/file1.sh" ] 
}

@test "Files with max depth in another dir" {
	mkdir dir1/dir2
	cp dir1/file1.sh dir1/dir2/file1.java
	run files -m 1 -d dir1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ]
}

@test "All files in another dir with max depth" {
	run files -a -m 1 -d dir1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[2]}" = "15 dir1/file1" ]
	[ "${lines[3]}" = "15 dir1/file1" ] ||\
	[ "${lines[3]}" = "15 dir1/file1.sh" ] 
}
