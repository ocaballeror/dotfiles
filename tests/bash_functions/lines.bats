#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp
	mkdir dir1 dir2
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
	cp dir1/file1.sh dir2/file1.other
	echo "line" >> dir2/file1.other

	cp dir1/file1.sh dir1/file1.c
	echo "line" >> dir1/file1.c
	echo "line" >> dir1/file1.c

	cp dir1/file1.sh file1.js
	echo "line" >> file1.js
	echo "line" >> file1.js
	echo "line" >> file1.js
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Basic lines" {
	run lines
	[[ ${lines[0]} =~ \ *50\ total ]]
	[[ ${lines[1]} =~ \ *18\ file1.js ]]
	[[ ${lines[2]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[3]} =~ \ *15\ dir1/file1.sh ]]
}

@test "Lines in another dir" {
	run lines -d dir1
	[[ ${lines[0]} =~ \ *32\ total ]]
	[[ ${lines[1]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[2]} =~ \ *15\ dir1/file1.sh ]]
}

@test "Lines with depth" {
	run lines -m 1
	[[ $output =~ \ *18\ file1.js ]]

	run lines -m 0
	[ $status != 0 ]
}

@test "All lines" {
	run lines -a

	[[ ${lines[0]} =~ \ *66\ total ]]
	[[ ${lines[1]} =~ \ *18\ file1.js ]]
	[[ ${lines[2]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[3]} =~ \ *16\ dir2/file1.other ]]
	[[ ${lines[4]} =~ \ *15\ dir1/file1.sh ]]
}

@test "All lines with max depth" {
	cp dir2/file1.other .
	run lines -a -m 1

	[[ ${lines[0]} =~ \ *34\ total ]]
	[[ ${lines[1]} =~ \ *18\ file1.js ]]
	[[ ${lines[2]} =~ \ *16\ file1.other ]]
}

@test "Lines with max depth in another dir" {
	mkdir dir1/dir3
	cp dir1/file1.sh dir1/dir3/file1.java
	run lines -m 1 -d dir1

	[[ ${lines[0]} =~ \ *32\ total ]]
	[[ ${lines[1]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[2]} =~ \ *15\ dir1/file1.sh ]]
}

@test "All lines with max depth in another dir" {
	run lines -a -m 1 -d dir1

	[[ ${lines[0]} =~ \ *48\ total ]]
	[[ ${lines[1]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[2]} =~ \ *16\ dir1/file1.other ]]
	[[ ${lines[3]} =~ \ *15\ dir1/file1.sh ]]
}

@test "Lines in one filetype" {
	run lines sh

	[[ ${lines[0]} =~ \ *15\ dir1/file1.sh ]]
}

@test "Lines in a list of filetypes" {
	run lines sh js

	[[ ${lines[0]} =~ \ *33\ total ]]
	[[ ${lines[1]} =~ \ *18\ file1.js ]]
	[[ ${lines[2]} =~ \ *15\ dir1/file1.sh ]]
}

@test "Lines in a list of inexistent filetypes" {
	run lines asdfasdf

	[[ ${lines[0]} =~ \ *0\ total ]]
}

@test "Lines in a list of filetypes with max depth" {
	run lines -m 1 sh js

	[[ ${lines[0]} =~ \ *18\ file1.js ]]
}

@test "Lines in a list of filetypes in another dir" {
	run lines -d dir1 c sh

	[[ ${lines[0]} =~ \ *32\ total ]]
	[[ ${lines[1]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[2]} =~ \ *15\ dir1/file1.sh ]]
}

@test "The full lines package" {
	mkdir dir1/dir3
	cp dir1/file1.sh dir1/dir3/file1.java
	run lines -m 1 -d dir1 c sh

	[[ ${lines[0]} =~ \ *32\ total ]]
	[[ ${lines[1]} =~ \ *17\ dir1/file1.c ]]
	[[ ${lines[2]} =~ \ *15\ dir1/file1.sh ]]
}
