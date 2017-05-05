#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

wsetup() {
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
	
	touch file1 file2
	mkdir dir1 dir2
}

wteardown() {
	cd "$HOME"
	rm -rf "$temp"
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Standard cpvm" {
	wsetup
	cpvm file1 Arch
	ls vbox/Arch/file1
	rm vbox/Arch/file1
}

@test "Cpvm: Directory copy + case sensitivity" {
	cpvm dir1 arch
	ls -d vbox/arch/dir1
	rm -r vbox/arch/dir1
}

@test "Cpvm case insensitivity" {
	# Case insensitivity
	rm -r vbox/arch
	cpvm file1 arch
	ls vbox/Arch/file1
	rm vbox/Arch/file1
}

@test "Cpvm: vb|vmw argument processing" {
	cpvm vbox file1 Arch
	ls vbox/Arch/file1
	cpvm vmw file1 Arch
	ls vmware/Arch/file1
	rm vbox/Arch/file1
	rm vmware/Arch/file1
}

@test "Cpvm: vmware as fallback" {
	# Vmware as fallback
	rm -r vbox
	cpvm file1 Arch
	ls vmware/Arch/file1
	vmware/Arch/file1
}

@test "Cpvm: cp switches" {
	cpvm -s file1 arch
	ls vmware/arch/file1
	bash -c "stat vmware/arch/file1 | grep 'symbolic link'"
	rm vmware/arch/file1
}

@test "Cpvm: Argument reversing" {
	cpvm Arch file1
	ls vmware/Arch/file1
	rm vmware/Arch/file1
	wteardown
}
