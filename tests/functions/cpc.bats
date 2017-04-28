#!/usr/bin/env bats

load $HOME/.bash_functions

wsetup(){
	temp="$(mktemp -d)"
	cd $temp
}

wteardown() {
	cd "$HOME"
	rm -rf "$temp"
}

@test "Standard cpc" {
	wsetup

	mkdir dir1
	touch file1
	cpc file1 dir1
	[ "$(pwd)" = "$temp/dir1" ]
	ls file1
	cd ..
}

@test "CPC directories" {
	mkdir dir2
	touch dir2/file2
	cpc dir2 dir1
	[ "$(pwd)" = "$temp/dir1" ]
	ls -d dir2
	ls dir2/file2
	cd ..
}

@test "CPC with cp arguments" {
	# Check if it accepts cp arguments
	rm -rf dir1/dir2
	cpc -s dir2 dir1
	[ "$(pwd)" = "$temp/dir1" ]
	ls -d /dir2
	ls dir2/file2
	stat dir2 | grep 'symbolic link' 
	cd ..

	wteardown
}
