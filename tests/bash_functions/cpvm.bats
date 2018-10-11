#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	temp="$(mktemp -d)"
	mkdir $temp/vbox
	mkdir $temp/vmware
	cd $temp

	oldvbox="$VBOXHOME"
	oldvmw="$VMWAREHOME"
	export VBOXHOME="$temp/vbox"
	export VMWAREHOME="$temp/vmware"

	mkdir $VBOXHOME/arch
	mkdir $VBOXHOME/Arch
	mkdir $VMWAREHOME/arch
	mkdir $VMWAREHOME/Arch
	
	echo "file 1" >file1
	echo "file 2" >file2
	mkdir dir1 dir2
}

teardown() {
	cd "$HOME"
	rm -rf "$temp"
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Basic cpvm" {
	run cpvm file1 Arch
	[ "$status" = 0 ]
	[ -f vbox/Arch/Shared/file1 ]
}

@test "Cpvm with multiple files" {
	run cpvm file1 file2 Arch
	[ "$status" = 0 ]
	[ -f vbox/Arch/Shared/file1 ]
	[ -f vbox/Arch/Shared/file2 ]
}

@test "Cpvm: quoted filenames with spaces" {
	filename='a name with spaces'
	touch "$filename"
	run cpvm "$filename" Arch

	[ "$status" = 0 ]
	[ -f "vbox/Arch/Shared/$filename" ]
}

@test "Cpvm: filenames with escaped spaces" {
	touch a\ name\ with\ spaces
	run cpvm a\ name\ with\ spaces Arch

	[ "$status" = 0 ]
	[ -f vbox/Arch/Shared/a\ name\ with\ spaces ]
}

@test "Cpvm: Directory copy + case sensitivity" {
	run cpvm dir1 arch

	[ -d vbox/arch/Shared/dir1 ]
}

@test "Cpvm case insensitivity" {
	# Case insensitivity
	rm -r vbox/arch
	run cpvm file1 arch
	[ "$status" = 0 ]
	[ -f vbox/Arch/Shared/file1 ]
}

@test "Cpvm: vb|vmw argument processing" {
	run cpvm vbox file1 Arch
	[ "$status" = 0 ]
	[ -f vbox/Arch/Shared/file1 ]
	run cpvm vw file1 Arch
	[ "$status" = 0 ]
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: Vmware as fallback" {
	# Vmware as fallback
	rm -r vbox
	run cpvm file1 Arch
	[ "$status" = 0 ]
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: cp switches" {
	oldcontent="$(cat file1)"
	run cpvm file1 arch
	[ "$status" = 0 ]
	[ -f vbox/arch/Shared/file1 ]

	echo "more stuff" >file1	
	run cpvm -n file1 arch
	[ "$status" = 0 ]

	[ "$(cat vbox/arch/Shared/file1)" = "$oldcontent" ]
}

@test "Cpvm: Argument reversing" {
	run cpvm Arch file1
	[ "$status" = 0 ]
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: Argument reversing with multiple files" {
	run cpvm Arch file1 file2
	[ "$status" = 0 ]
	[ -f vmware/Arch/Shared/file1 ]
	[ -f vmware/Arch/Shared/file2 ]
}
