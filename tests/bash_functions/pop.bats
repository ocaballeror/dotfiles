#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

standard_setup() {
	content1="Hello world"
	content2="Hello world 2"
	file1="file1"
	file2="file2"

	run folder $loop
   	[ -d folder ] || skip "Folder not working properly"
	echo "$content1" > folder/$file1
	echo "$content2" > folder/$file2
	[ -f folder/$file1 ] || skip "Folder not working properly"
	[ -f folder/$file2 ] || skip "Folder not working properly"
	run folder -k
}

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

@test "Pop one file" {
	standard_setup
	run pop $file1 $loop
	[ $status = 0 ]
	[ -f $file1 ]
	[ ! -d folder ]
	[ "$(cat $file1)" = "$content1" ]
}

@test "Pop multiple files" {
	standard_setup
	run pop $file1 $file2 $loop
	[ -f $file1 ]
	[ -f $file2 ]
	[ ! -d folder ]
	[ "$(cat $file1)" = "$content1" ]
	[ "$(cat $file2)" = "$content2" ]
}

@test "Pop quoted filename with spaces" {
	filename='a name with spaces'

	run folder $loop
	[ -d folder ] || skip "Folder not working properly"
	touch "folder/$filename"
	[ -f "folder/$filename" ] || skip "Folder not working properly"
	run folder -k

	run pop "$filename" $loop
	[ -f "$filename" ]
	[ ! -d folder ]
}

@test "Pop filename with escaped spaces" {
	run folder $loop
	[ -d folder ] || skip "Folder not working properly"
	touch folder/a\ name\ with\ spaces
	[ -f folder/a\ name\ with\ spaces ] || skip "Folder not working properly"
	run folder -k

	run pop a\ name\ with\ spaces $loop
	[ -f a\ name\ with\ spaces ]
	[ ! -d folder ]
}
