#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	cwd="$PWD"
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
	[ $PWD = $VBOXHOME/Arch ]
}

@test "Case sensitive cdvm" {
	cdvm arch
	[ $PWD = $VBOXHOME/arch ]
}

@test  "Case insensitive cdvm" {
	rm -rf $VBOXHOME/arch
	cdvm arch
	[ $PWD = $VBOXHOME/Arch ]
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

@test "Cdvm: Fallback vmware for inexistent VBOXHOME" {
	rm -rf $VBOXHOME
	cdvm arch
	[ $PWD = $VMWAREHOME/arch ]
}


@test "Cdvm: Fallback vmware for unset VBOXHOME" {
	unset VBOXHOME
	cdvm arch
	[ $PWD = $VMWAREHOME/arch ]
}

@test "Cdvm to virtualbox home" {
	cdvm vb
	[ $PWD = $VBOXHOME ]
}

@test "Cdvm to vmware home" {
	cdvm vw
	[ $PWD = $VMWAREHOME ]
}

@test "Cdvm to inexistent virtualbox home" {
	rm -rf $VBOXHOME
	run cdvm vb
	[ $status != 0 ]
	[ "$PWD" = "$cwd" ]
}

@test "Cdvm to inexistent vmware home" {
	rm -rf $VMWAREHOME
	run cdvm vw
	[ $status != 0 ]
	[ "$PWD" = "$cwd" ]
}

@test "Cdvm with no arguments" {
	cdvm 
	[ $PWD = $VBOXHOME ]
}

@test "Cdvm with no arguments, inexistent default home" {
	rm -rf $VBOXHOME
	cdvm 
	[ "$PWD" = "$VMWAREHOME" ]
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
