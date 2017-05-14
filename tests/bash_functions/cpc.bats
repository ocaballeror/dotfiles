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
	[ "$(pwd)" = "$temp/dir1" ]
	[ -f file1 ]
}

@test "Cpc directories" {
	mkdir dir1 dir2
	touch dir2/file2
	cpc dir2 dir1
	[ "$(pwd)" = "$temp/dir1" ]
	[ -d dir2 ]
	[ -f dir2/file2 ]
}

@test "Cpc with cp arguments" {
	# Check if it accepts cp arguments
	mkdir dir1 
	echo "test" >dir1/file1
	echo "test 2" >file1
	cpc -n file1 dir1
	[ "$(pwd)" = "$temp/dir1" ]
	[ -f file1 ]
	[ "$(cat file1)" = "test" ]
}
