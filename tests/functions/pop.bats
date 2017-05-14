#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp
	
	disk="fakedisk"
	dd if=/dev/zero of=$disk  bs=1MiB count=4
	sudo mkfs.ext4 $disk
	loop="$(sudo losetup --find --show $disk)"

	content1="Hello world"
	content2="Hello world 2"
	file1="file1"
	file2="file2"

	run folder $loop
   	[ -d folder ] || skip "Folder not working properly"
	echo "$content1" > folder/$file1
	echo "$content2" > folder/$file2
	[ -f folder/$file1 ]
	[ -f folder/$file2 ]
	run folder -k 
}

teardown() {
	grep -qs $loop /proc/mounts && sudo umount $loop 
	sudo losetup --detach $loop

	cd "$HOME"
	rm -rf "$temp"
}

@test "Pop one file" {
	run pop $file1 $loop
	[ $status = 0 ]
	[ -f $file1 ]
	[ ! -d folder ]
	[ "$(cat $file1)" = "$content1" ]
}

@test "Pop multiple files" {
	run pop $file1 $file2 $loop
	[ -f $file1 ]
	[ -f $file2 ]
	[ ! -d folder ]
	[ "$(cat $file1)" = "$content1" ]
	[ "$(cat $file2)" = "$content2" ]
}
