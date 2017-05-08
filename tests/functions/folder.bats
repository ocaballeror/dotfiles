#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	cd $temp
	
	dd if=/dev/zero of=fakedisk  bs=1MiB count=8
	loop="$(sudo losetup --find --show fakedisk)"
}

teardown() {
	sudo umount $loop || true
	sudo losetup --detach $loop

	cd "$HOME"
	rm -rf "$temp"
}

@test "Folder ext4" {
	skip "Not yet implemented"
	sudo mkfs.ext4 fakedisk
	folder $loop
	touch folder/file

	sudo umount folder
	sudo mount $loop folder
	[ -f folder/file ]
}
