#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"	
	cd "$temp"

	mkdir dir1
	mkdir dir1/dir2
	mkdir dir1/dir2/dir3
	touch dir1/file1
	touch dir1/file2
	touch dir1/dir2/file3
	touch dir1/dir2/file4
	touch dir1/dir2/dir3/file5
	touch dir1/dir2/dir3/file6
}

teardown() {
	cd "$HOME"
	rmdir "$temp"
}

@test "Standard dump" {
	dump dir1
	run ls dir1/file1
	[ $status != 0 ]

	run ls dir1/file2
	[ $status != 0 ]

	[ -d dir1  ]
	[ -f file1 ]
	[ -f file2 ]

	[ -d dir2       ]
	[ -f dir2/file3 ]
	[ -f dir2/file4 ]

	[ -d dir2/dir3       ]
	[ -f dir2/dir3/file5 ]
	[ -f dir2/dir3/file6 ]
}

@test "Aggressive dump" {
	dump -a dir1

	run bash -c "find dir1 | wc -l"
	[ $output = 1 ]

	[ ! -d dir1 ]
	[ -f file1  ]
	[ -f file2  ]

	[ -d dir2       ]
	[ -f dir2/file3 ]
	[ -f dir2/file4 ]

	[ -d dir3       ]
	[ -f dir3/file5 ]
	[ -f dir3/file6 ]
}

@test "Superaggressive dump" {
	dump -aa dir1

	run bash -c "find dir1 | wc -l"
	[ $output = 1 ]

	[ ! -d dir1 ]
	[ -f file1  ]
	[ -f file2  ]

	[ ! -d dir2 ]
	[ -f file3  ]
	[ -f file4  ]

	[ ! -d dir3 ]
	[ -f file5  ]
	[ -f file6  ]
}
