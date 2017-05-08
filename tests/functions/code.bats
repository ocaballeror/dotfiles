#!/usr/bin/env bats

#I don't know how to test this one, so I'm going to try it with 
#a package from every repository


load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup() {
	! hash pacman 2>/dev/null && skip "This script only works on ArchLinux"
	temp="$(mktemp -d)"
	cd $temp
}

teardown(){
	cd "$HOME"
	rm -rf $temp
}

@test "Core code" {
	run code curl
	[ "$(ls -d curl-* | wc -l)" -ge 1 ]
	[ -f curl-*/README ]
	[ -f curl-*/AUTHORS ]
	[ -f curl-*/aclocal.m4 ]
}

@test "Extra code" {
	run code lzop

	[ -d lzop/src ] && cd lzop/src
	[ "$(ls -d lzop* | wc -l)" -ge 1 ]
	[ -f lzop*/README ]
	[ -f lzop*/AUTHORS ]
	[ -f lzop*/aclocal.m4 ]
}

@test "Community code" {
	run code rofi

	[ -d rofi/src ] && cd rofi/src
	[ "$(ls -d rofi* | wc -l)" -ge 1 ]
	[ -f rofi*/README.md ]
	[ -f rofi*/AUTHORS ]
	[ -f rofi*/aclocal.m4 ]
}
	
@test "Multilib code" {
	run code lib32-libtiff
	echo "$(pwd)"
	echo "$(ls)"
	echo "$(ls lib32-libtiff)" 
	echo "$(ls lib32-libtiff/src)"
	echo "${lines[@]}" 

	[ -d lib32-libtiff/src ] && cd lib32-libtiff/src
	[ "$(ls -d tiff* | wc -l)" -ge 1 ]
	[ -f tiff*/README ]
	[ -f tiff*/VERSION ]
	[ -f tiff*/aclocal.m4 ]
}

@test "Aur code" {
	run code vpnks

	[ -d vpnks/src ] && cd vpnks/src
	[ -d vpnkillswitch-master ]
	[ "$(ls vpnkillswitch-master | wc -l)" -ge 1 ]
}
