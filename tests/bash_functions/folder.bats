#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp
	
	disk="fakedisk"
	dd if=/dev/zero of=$disk  bs=1MiB count=4
	sudo mkfs.ext4 $disk
	loop="$(sudo losetup --find --show $disk)"
}

teardown() {
	grep -qs $loop /proc/mounts && sudo umount $loop 
	sudo losetup --detach $loop

	cd "$HOME"
	rm -rf "$temp"
}

@test "Folder ext4" {
	run folder $loop
	touch folder/file

	sudo umount folder
	[ ! -f folder/file ]

	sudo mount $loop folder
	[ -f folder/file ]
}

@test "Folder kill" {
	mkdir folder

	sudo mount $loop folder
	sudo touch folder/file

	folder -k
	! grep -qs $loop /proc/mounts
	[ ! -d folder ]
}

@test "Folder and folder kill" {
	run folder $loop
	touch folder/file

	folder -k
	! grep -qs $loop /proc/mounts
	[ ! -d folder ]
}

@test "Folder and kill with existing folder" {
	mkdir folder
	touch folder/file1
	
	run folder $loop
	[ ! -f folder/file1 ]
	touch folder/file2		
	folder -k

	[ -d folder ]
	[ ! -f folder/file2 ]
	[ -f folder/file1 ]
}

@test "Folder with another name" {
	run folder -o fs $loop 
	touch fs/file1

	folder -k fs
	[ ! -d fs ]
	! grep -qs $loop /proc/mounts
}

@test "Folder with another name with spaces" {
	dname="dir name"

	run folder -o "$dname" $loop
	[ -d "$dname" ]
	touch "$dname/file"

	folder -k "$dname"

	[ ! -d "$dname" ]
	! grep -qs $loop /proc/mounts
}

@test "Folder kill while inside" {
	cwd="$(pwd)"
	run folder $loop
	cd folder
	touch file
	folder -k

	[ "$(pwd)" = "$cwd" ]
	[ ! -d folder ]
	! grep -qs $loop /proc/mounts
}

@test "Folder kill while two levels inside" {
	cwd="$(pwd)"
	run folder $loop
	cd folder
	mkdir folder
	cd folder
	touch file
	folder -k

	[ "$(pwd)" = "$cwd" ]
	[ ! -d folder ]
	! grep -qs $loop /proc/mounts
}

@test "Folder kill inside folder alongside folder" {
	cwd="$(pwd)"
	disk2="fakedisk2"
	dd if=/dev/zero of=$disk2  bs=1MiB count=8
	sudo mkfs.ext4 $disk2
	loop2="$(sudo losetup --find --show $disk2)"
	run folder $loop
	cd folder
	run folder $loop2

	folder -k
	! test -d folder 
	[[ $(dirname $(pwd)) =~ \ *$cwd\ * ]]
	! grep -qs $loop2 /proc/mounts

	folder -k
	[ ! -d folder ]
	[[ $(dirname $cwd) =~ \ *$pwd\ * ]]
	! grep -qs $loop /proc/mounts
}
