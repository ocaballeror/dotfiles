#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

teardown() {
	name=$(swap_name)
	while [ -n "$name" ]; do
		sudo swapoff "$name"
		sudo rm "$name"
		name=$(swap_name)
	done
	true
}

# Check if a swapfile is being used
is_swapping() {
	swapon --noheadings --show=type | grep -q 'file$'
}

swap_name() {
	swapon --show=name | tail -1 | tr -d ' '
}
swap_size() {
	swapon --show=size | tail -1 | tr -d ' '
}

@test "Standard createswap" {
	swapfile="/swapfile"
	[ -f "$swapfile" ] && skip "$swapfile already exists"
	is_swapping && skip "Already swapping"
	swaps=$(swapon --noheadings --show | wc -l)
	createswap 1
	[ "$(swapon --noheadings --show | wc -l)" = $((swaps + 1)) ]
	[ "$(swap_name)" = "$swapfile" ]
	[ "$(swap_size)" = "1024M" ]
}

@test "Createswap on a different file" {
	is_swapping && skip "Already swapping"
	tmp=$(mktemp)
	rm $tmp
	createswap "$tmp"
	[ "$(swap_name)" = "$tmp" ]
	[ "$(swap_size)" = "8G" ]
}

@test "Createswap with a different size" {
	swapfile="/swapfile"
	is_swapping && skip "Already swapping"
	createswap 1
	[ "$(swap_name)" = "$swapfile" ]
	[ "$(swap_size)" = "1024M" ]
}

@test "Createswap on a different file with different size" {
	is_swapping && skip "Already swapping"
	tmp=$(mktemp)
	rm $tmp
	createswap "$tmp" 1
	[ "$(swap_name)" = "$tmp" ]
	[ "$(swap_size)" = "1024M" ]
}

@test "Createswap: force multiple files" {
	tmp=$(mktemp)
	tmp2=$(mktemp)
	rm $tmp $tmp2
	createswap -f "$tmp" 1
	[ "$(swap_name)" = "$tmp" ]
	[ "$(swap_size)" = "1024M" ]
	createswap -f "$tmp2" 1
	[ "$(swap_name)" = "$tmp2" ]
	[ "$(swap_size)" = "1024M" ]
}

@test "Createswap twice (without forcing)" {
	tmp=$(mktemp)
	tmp2=$(mktemp)
	rm $tmp $tmp2
	createswap -f "$tmp" 1
	[ "$(swap_name)" = "$tmp" ]
	[ "$(swap_size)" = "1024M" ]
	run createswap "$tmp2" 1
	[ $status = 2 ]
	[ "$(swap_name)" = "$tmp" ]
	[ "$(swap_size)" = "1024M" ]
}

@test "Createswap on existing file" {
	tmp=$(mktemp)
	run createswap $tmp 1
	[ $status != 0 ]
	[ "$(swap_name)" != "$tmp" ]
	[ "$(swap_size)" != "1024M" ]
}
