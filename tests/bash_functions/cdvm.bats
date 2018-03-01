#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	current="$PWD"
	temp=$(mktemp -d)

	mkdir $temp/vbox
	mkdir $temp/vmware

	oldvbox="$VBOXHOME"
	oldvmw="$VMWAREHOME"
	export VBOXHOME="$temp/vbox"
	export VMWAREHOME="$temp/vmware"

	mkdir $VBOXHOME/arch
	mkdir $VBOXHOME/Arch
	mkdir $VMWAREHOME/arch
	mkdir $VMWAREHOME/Arch
}

teardown() {
	cd "$cwd"
	rm -rf $temp
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Basic cdvm" {
	cdvm Arch
	[ "$PWD" = "$VBOXHOME/Arch" ]
}

@test "Case sensitive cdvm" {
	cdvm arch
	[ $PWD = $VBOXHOME/arch ]
}

@test "Case insensitive cdvm" {
	rm -rf $VBOXHOME/arch
	cdvm arch
	[ $PWD = $VBOXHOME/Arch ]
}

@test "Cdvm to path with spaces" {
	mkdir -p "$temp/VirtualBox VMs/newvm"
	export VBOXHOME="$temp/VirtualBox VMs"
	cdvm newvm
	echo "$PWD"
	[ "$PWD" = "$VBOXHOME/newvm" ]
}

@test "Cdvm case insensitive over fallback vmware" {
	rm -rf "$VBOXHOME/Arch"
	cdvm Arch
	[ $PWD = $VBOXHOME/arch ]
}

@test "Cdvm case insensitive over fallback vmware" {
	rm -rf "$VBOXHOME/Arch"
	cdvm Arch
	[ $PWD = $VBOXHOME/arch ]
}

@test "Cdvm to vmware vm" {
	cdvm vw arch
	[ $PWD = $VMWAREHOME/arch ]
}

@test "Fallback vmware for cdvm" {
	rm -rf $VBOXHOME
	cdvm Arch
	[ $PWD = $VMWAREHOME/Arch ]
}

@test "Cdvm to virtualbox home" {
	cdvm vb
	[ $PWD = $VBOXHOME ]
}

@test "Cdvm to vmware home" {
	cdvm vw
	[ $PWD = $VMWAREHOME ]
}

@test "Cdvm with no arguments" {
	cdvm 
	[ $PWD = $VBOXHOME ]
}

@test "Cdvm with no arguments and no vboxhome" {
	rm -rf "$VBOXHOME"
	cdvm
	[ $PWD = $VMWAREHOME ]
}

@test "Cdvm to inexistent vm" {
	cwd="$PWD"
	run cdvm inexistent
	[ $status != 0 ]
	[ $PWD = $cwd ]
}
	
@test "Cdvm to inexistent vm with inexisting vboxhome" {
	cd /
	rm -rf $VBOXHOME
	cdvm
	[ $PWD = $VMWAREHOME ]
}
