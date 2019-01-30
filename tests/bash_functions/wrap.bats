#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	temp=$(mktemp -d)
	pushd . >/dev/null
	cd $temp
}

teardown() {
	popd >/dev/null
	rm -rf $temp
}

@test "Basic wrap" {
	touch file
	[ -f file ]
	wrap file
	[ -d file ]
	[ -f file/file ]
}

@test "Wrap directory" {
	mkdir dir
	touch dir/file
	[ -d dir ]
	[ -f dir/file ]
	wrap dir
	[ -d dir ]
	[ -d dir/dir ]
	[ -f dir/dir/file ]
}

@test "Wrap filename with spaces" {
	filename="file name"
	touch "$filename"
	[ -f "$filename" ]
	wrap "$filename"
	[ -d "$filename" ]
	[ -f "$filename/$filename" ]
}

@test "Wrap inexistent" {
	run wrap file
	[ $status = 2 ]
}

@test "Wrap with no arguments" {
	run wrap
	[ $status = 1 ]
}
