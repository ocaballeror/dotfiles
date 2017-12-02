#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	current="$(pwd)"
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
	cd "$HOME"
	rm -rf $temp
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Basic cdvm" {
	cdvm Arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "Case sensitive cdvm" {
	cdvm arch
	[ $(pwd) = $VBOXHOME/arch ]
}

@test  "Case insensitive cdvm" {
	rm -rf $VBOXHOME/arch
	cdvm arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "Cdvm case insensitive over fallback vmware" {
	rm -rf "$VBOXHOME/Arch"
	cdvm Arch
	[ $PWD = $VBOXHOME/arch ]
}

@test "Cdvm to vmware vm" {
	cdvm vw arch
	[ $(pwd) = $VMWAREHOME/arch ]
}

@test "Fallback vmware for cdvm" {
	rm -rf $VBOXHOME/Arch
	cdvm arch
	[ $(pwd) = $VMWAREHOME/arch ]
}

@test "Cdvm to virtualbox home" {
	cdvm vb
	[ $(pwd) = $VBOXHOME ]
}

@test "Cdvm to vmware home" {
	cdvm vw
	[ $(pwd) = $VMWAREHOME ]
}

@test "Cdvm with no arguments" {
	cdvm 
	[ $(pwd) = $VBOXHOME ]
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
	echo "$(pwd)"
	echo "$cwd" 
	[ $(pwd) = $cwd ]
}
	
@test "Cdvm to inexistent vm with inexisting vboxhome" {
	cd /
	rm -rf $VBOXHOME
	cdvm
	[ $(pwd) = $VMWAREHOME ]
}
