#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"	
	cd "$temp"

	mkdir -p dir1/dir2/dir3
	touch dir1/file1
	touch dir1/file2
	touch dir1/dir2/file3
	touch dir1/dir2/file4
	touch dir1/dir2/dir3/file5
	touch dir1/dir2/dir3/file6
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Standard dump" {
	dump dir1
	
	[ ! -d dir1 ]
	[ -f file1  ]
	[ -f file2  ]

	[ -d dir2       ]
	[ -f dir2/file3 ]
	[ -f dir2/file4 ]

	[ -d dir2/dir3       ]
	[ -f dir2/dir3/file5 ]
	[ -f dir2/dir3/file6 ]
}

@test "Aggressive dump" {
	dump -a dir1

	[ ! -d dir1 ]
	[ -f file1  ]
	[ -f file2  ]
	[ -f file3  ]
	[ -f file4  ]
	[ -f file5  ]
	[ -f file6  ]
}

@test "Dump the current folder" {
	cd dir1
	dump .

	[ ! -d dir1 ]
	[ -f file1  ]
	[ -f file2  ]

	[ -d dir2       ]
	[ -f dir2/file3 ]
	[ -f dir2/file4 ]

	[ -d dir2/dir3       ]
	[ -f dir2/dir3/file5 ]
	[ -f dir2/dir3/file6 ]
}

@test "Dump filenames with spaces" {
	mv dir1/dir2/dir3/file6 'dir1/dir2/dir3/file 6'
	mv dir1/dir2/dir3 'dir1/dir2/dir 3'
	mv dir1/file2 'dir1/file 2'
	mv dir1 'dir 1'
	dump 'dir 1'
	
	[ ! -d 'dir 1' ]
	[ -f file1     ]
	[ -f 'file 2'  ]

	[ -d dir2       ]
	[ -f dir2/file3 ]
	[ -f dir2/file4 ]

	[ -d "dir2/dir 3"        ]
	[ -f "dir2/dir 3/file5"  ]
	[ -f "dir2/dir 3/file 6" ]
}

@test "Dump with errors when moving" {
	mkdir dir2
	touch dir2/file7
	run dump dir1
	[ $status != 0 ]

	[ -d dir2 ]
	[ -f dir2/file7 ]
	[ -f file1 ]
	[ -f file2 ]
	[ -d dir1/dir2 ]
	[ -f dir1/dir2/file3 ]
	[ -f dir1/dir2/file4 ]
	[ -d dir1/dir2/dir3 ]
}
