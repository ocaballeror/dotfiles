#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp
	mkdir dir1 dir1/dir3
	touch dir1/file1.sh
	touch dir1/file2.sh
	touch dir1/file3.sh
	touch dir1/file4.sh
	touch dir1/file5.sh
	touch dir1/file1.js
	touch dir1/file2.js
	touch dir1/file3.js
	touch dir1/file4.js
	touch dir1/dir3/file1.py
	touch dir1/dir3/file2.py
	touch file1.c
	touch file1.other
	touch dir1/file2.other
	touch dir1/dir3/file3.other
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Basic files" {
	run files
	[[ ${lines[0]} =~ \ *12\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
	[[ ${lines[3]} =~ \ *2\ py ]]
	[[ ${lines[4]} =~ \ *1\ c  ]]
}

@test "Files in another dir" {
	run files -d dir1
	[[ ${lines[0]} =~ \ *11\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
	[[ ${lines[3]} =~ \ *2\ py ]]
}

@test "Files with depth" {
	run files -m 1
	[[ ${lines[0]} =~ \ *1\ total ]]
	[[ ${lines[1]} =~ \ *1\ c ]]

	run files -m 0
	[ $status != 0 ]
}

@test "File count" {
	run files -c
	[[ ${lines[0]} =~ \ *15 ]]
}

@test "File count in another dir" {
	run files -c -d dir1
	[[ ${lines[0]} =~ \ *13 ]]
}
@test "File count with max depth" {
	run files -c -m 1
	[[ ${lines[0]} =~ \ *2 ]]
}
@test "File count in another dir with max depth" {
	run files -c -m 1 -d dir1
	[[ ${lines[0]} =~ \ *10 ]]
}

@test "All files" {
	run files -a

	[[ ${lines[0]} =~ \ *15\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
	[[ ${lines[3]} =~ \ *3\ other ]]
	[[ ${lines[4]} =~ \ *2\ py ]]
	[[ ${lines[5]} =~ \ *1\ c  ]]
}

@test "All files with max depth" {
	run files -a -m 1

	[[ ${lines[0]} =~ \ *2\ total ]]
	[[ ${lines[1]} =~ \ *1\ c ]] && [[ ${lines[2]} =~ \ *1\ other ]]||\
	[[ ${lines[1]} =~ \ *1\ other ]] && [[ ${lines[2]} =~ \ *1\ c ]]
}

@test "Files with max depth in another dir" {
	run files -m 1 -d dir1

	[[ ${lines[0]} =~ \ *9\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
}

@test "All files with max depth in another dir" {
	run files -a -m 1 -d dir1

	[[ ${lines[0]} =~ \ *10\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
	[[ ${lines[3]} =~ \ *1\ other ]]
}

@test "Files in one filetype" {
	run files sh

	[[ ${lines[0]} =~ \ *5\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
}

@test "Files in a list of filetypes" {
	run files sh js

	[[ ${lines[0]} =~ \ *9\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *4\ js ]]
}

@test "Files in a list of inexistent filetypes" {
	run files asdfasdf

	[[ ${lines[0]} =~ \ *0\ total ]]
}

@test "Files in a list of filetypes with max depth" {
	run files -m 1 sh js c

	[[ ${lines[0]} =~ \ *1\ total ]]
	[[ ${lines[1]} =~ \ *1\ c ]]
}


@test "Files in a list of filetypes in another dir" {
	run files -d dir1 c sh py

	[[ ${lines[0]} =~ \ *7\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
	[[ ${lines[2]} =~ \ *2\ py ]]
}

@test "The full files package" {
	run files -m 1 -d dir1 c sh

	[[ ${lines[0]} =~ \ *5\ total ]]
	[[ ${lines[1]} =~ \ *5\ sh ]]
}
