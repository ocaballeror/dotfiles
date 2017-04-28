#!/usr/bin/env bats

#I don't know how to test this one, so I'm going to try it with 
#a package from every repository


load ~/.bash_functions

wsetup() {
	temp="$(mktemp -d)"
	cd $temp
}

wteardown(){
	cd "$HOME"
	rm -rf $temp
}

@test "Multilib code" {
	wsetup
	code lib32-libtiff
	[ "$(ls -d acl-* | wc -l)" -ge 1 ]
	cd acl-*
	[ -f README ]
	[ -f VERSION ]
	[ -f aclocal.m4 ]
}

@test "Community code" {
	cd ../../../
	code rofi
	[ "$(ls -d rofi-* | wc -l)" -ge 1 ]
	cd rofi-*
	[ -f README.md ]
	[ -f AUTHORS ]
	[ -f aclocal.m4 ]
}
	
@test "Extra code" {
	cd ../../../
	code lzop
	[ "$(ls -d lzop-* | wc -l)" -ge 1 ]
	cd lzop-*
	[ -f README ]
	[ -f AUTHORS ]
	[ -f aclocal.m4 ]
}
	
@test "Core code" {
	cd ../../../
	code gmp
	[ "$(ls -d gmp-* | wc -l)" -ge 1 ]
	[ -f README ]
	[ -f AUTHORS ]
	[ -f aclocal.m4 ]
}

@test "Aur code" {
	cd ../../../
	code vpnks
	[ -d vpnkillswitch-master ]
	[ "$(ls vpnkillswitch-master | wc -l)" -ge 1 ]
	cd ../../../
	wteardown
}
