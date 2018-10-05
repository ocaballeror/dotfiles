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
	cpvm file1 Arch
	[ -f vbox/Arch/Shared/file1 ]
}

@test "Cpvm with multiple files" {
	cpvm file1 file2 Arch
	[ -f vbox/Arch/Shared/file1 ]
	[ -f vbox/Arch/Shared/file2 ]
}

@test "Cpvm: quoted filenames with spaces" {
	filename='a name with spaces'
	touch "$filename"
	cpvm "$filename" Arch

	[ -f "vbox/Arch/Shared/$filename" ]
}

@test "Cpvm: filenames with escaped spaces" {
	touch a\ name\ with\ spaces
	cpvm a\ name\ with\ spaces Arch

	[ -f vbox/Arch/Shared/a\ name\ with\ spaces ]
}

@test "Cpvm: Directory copy + case sensitivity" {
	cpvm dir1 arch

	[ -d vbox/arch/Shared/dir1 ]
}

@test "Cpvm case insensitivity" {
	# Case insensitivity
	rm -r vbox/arch
	cpvm file1 arch
	[ -f vbox/Arch/Shared/file1 ]
}

@test "Cpvm: vb|vmw argument processing" {
	cpvm vbox file1 Arch
	[ -f vbox/Arch/Shared/file1 ]
	cpvm vw file1 Arch
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: Vmware as fallback" {
	# Vmware as fallback
	rm -r vbox
	cpvm file1 Arch
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: cp switches" {
	oldcontent="$(cat file1)"
	cpvm file1 arch
	[ -f vbox/arch/Shared/file1 ]

	echo "more stuff" >file1	
	cpvm -n file1 arch

	[ "$(cat vbox/arch/Shared/file1)" = "$oldcontent" ]
}

@test "Cpvm: Argument reversing" {
	cpvm Arch file1
	[ -f vmware/Arch/Shared/file1 ]
}

@test "Cpvm: Argument reversing with multiple files" {
	cpvm Arch file1 file2
	[ -f vmware/Arch/Shared/file1 ]
	[ -f vmware/Arch/Shared/file2 ]
}
