#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	hash gdfs 2>/dev/null || skip "Gdfs is not installed"
}

@test "Drive" {
	oldcount="$(find ~/Drive/ | wc -l)"
	drive
	count="$(find ~/Drive/ | wc -l)"
	[ $count -gt 0 ]
	[ $count != oldcount ]
}

@test "Drive kill" {
	drive -k
	count="$(find ~/Drive/ | wc -l)"
	[ $count -gt 0 ]
	[ $count != oldcount ]
}

@test "Drive with no caching" {
	drive -n
	ps aux | grep "find $HOME/Drive" | grep -v grep
	[ $? = 1 ]
	count="$(find ~/Drive/ | wc -l)"
	[ $count -gt 0 ]
	[ $count != oldcount ]

	drive -k
}
