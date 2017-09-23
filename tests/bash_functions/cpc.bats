#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	temp="$(mktemp -d)"
	cd $temp
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Standard cpc" {
	mkdir dir1
	touch file1
	cpc file1 dir1
	[ "$PWD" = "$temp/dir1" ]
	[ -f file1 ]
}

@test "Cpc directories" {
	mkdir dir1 dir2
	touch dir2/file2
	cpc dir2 dir1
	[ "$PWD" = "$temp/dir1" ]
	[ -d dir2 ]
	[ -f dir2/file2 ]
}

@test "Cpc multiple files" {
	mkdir dir1
	touch file1 file2
	cpc file1 file2 dir1

	[ "$PWD" = "$temp/dir1" ]
	[ -f file1 ]
	[ -f file2 ]
}

@test "Cpc with cp arguments" {
	# Check if it accepts cp arguments
	mkdir dir1 
	echo "test" >dir1/file1
	echo "test 2" >file1
	cpc -n file1 dir1
	[ "$PWD" = "$temp/dir1" ]
	[ -f file1 ]
	[ "$(cat file1)" = "test" ]
}

@test "Cpc quoted filenames with spaces" {
	filename='a name with spaces'
	mkdir dir1
	touch "$filename"
	cpc "$filename" dir1
	[ "$PWD" = "$temp/dir1" ]
	[ -f "$filename" ]
}

@test "Cpc filenames with escaped spaces" {
	mkdir dir1
	touch a\ name\ with\ spaces
	cpc a\ name\ with\ spaces dir1
	[ "$PWD" = "$temp/dir1" ]
	[ -f a\ name\ with\ spaces ]
}
