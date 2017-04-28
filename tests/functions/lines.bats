setup() {
	temp="$(mktemp -d)"
	cd $temp
	mkdir dir1
	cat > dir1/file1.sh <<EOF
line
line
line
line
line
line
line
line
line
line
line
line
line
line
line
EOF
	cp dir1/file1.sh dir1/file1.c
	cp dir1/file1.sh dir1/file1
	echo "line" >> dir1/file1.c
	cp dir1/file1.sh file1.js
	echo "line" >> file1.js
	echo "line" >> file1.js
}

@test "Basic lines" {
	run lines
	[ "${lines[0]}" = "48 total" ]
	[ "${lines[1]}" = "17 file1.js" ]
	[ "${lines[2]}" = "16 dir1/file1.c" ]
	[ "${lines[3]}" = "15 dir1/file1.sh" ]
}

@test "Lines in another dir" {
	run lines -d dir1	
	[ "${lines[0]}" = "31 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ]
}

@test "Lines with depth" {
	run lines -m 1
	[ $output = "17 file1.js" ]

	run lines -m 0
	[ $status != 0 ]
}

@test "All lines" {
	run lines -a

	[ "${lines[0]}" = "63 total" ]
	[ "${lines[1]}" = "17 file1.js" ]
	[ "${lines[2]}" = "16 dir1/file1.c" ]
	[ "${lines[3]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[3]}" = "15 dir1/file1" ]
	[ "${lines[4]}" = "15 dir1/file1" ] ||\
	[ "${lines[4]}" = "15 dir1/file1.sh" ] 
}

@test "All lines with depth" {
	run lines -a -m 1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[2]}" = "15 dir1/file1" ]
	[ "${lines[3]}" = "15 dir1/file1" ] ||\
	[ "${lines[3]}" = "15 dir1/file1.sh" ] 
}

@test "Lines with max depth in another dir" {
	mkdir dir1/dir2
	cp dir1/file1.sh dir1/dir2/file1.java
	run lines -m 1 -d dir1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ]
}

@test "All lines in another dir with max depth" {
	run lines -a -m 1 -d dir1

	[ "${lines[0]}" = "46 total" ]
	[ "${lines[1]}" = "16 dir1/file1.c" ]
	[ "${lines[2]}" = "15 dir1/file1.sh" ] ||\
	[ "${lines[2]}" = "15 dir1/file1" ]
	[ "${lines[3]}" = "15 dir1/file1" ] ||\
	[ "${lines[3]}" = "15 dir1/file1.sh" ] 
}
