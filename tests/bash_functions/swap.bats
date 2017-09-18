#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd "$temp"

	file1="file1"
	file2="file2"
	content1="Hello world"
	content2="Hello world 2"
	echo "$content1" > $file1
	echo "$content2" > $file2
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
}

# Is there even an "advanced" swap
@test "Basic swap" {
	swap $file1 $file2
	[ -f $file1 ]
	[ -f $file2 ]
	[ "$(cat $file1)" = "$content2" ]
	[ "$(cat $file2)" = "$content1" ]
}
