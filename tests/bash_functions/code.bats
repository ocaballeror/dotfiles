#!/usr/bin/env bats

# I didn't see a way to test the -f argument, so I didn't :)

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

check_conn() {
	if ! ping -c1 www.google.com >/dev/null 2>&1; then
		skip "No internet connection"
	fi
}

setup() {
	! hash pacman 2>/dev/null && skip "This script only works on ArchLinux"
	temp="$(mktemp -d)"
	cd $temp
}

teardown(){
	cd "$HOME"
	rm -rf $temp
}

@test "Code:ranger" {
	program=ranger
	code "$program"
	[ -f setup.py ]
	[ "$(basename "$PWD")" = "$program" ]

	# Check for broken links
	[[ -z $(find . -mindepth 1 -maxdepth 1 -type l ! -exec test -e {} \; -print) ]]
}

@test "Code:make" {
	program=make
	code  --no-checks "$program"
	[ -f configure ]
	[ "$(basename "$PWD")" = "$program" ]

	# Check for broken links
	[[ -z $(find . -mindepth 1 -maxdepth 1 -type l ! -exec test -e {} \; -print) ]]
}

@test "Code:maven" {
	program=maven
	code "$program"
	[ -f pom.xml ]
	[ "$(basename "$PWD")" = "$program" ]

	# Check for broken links
	[[ -z $(find . -mindepth 1 -maxdepth 1 -type l ! -exec test -e {} \; -print) ]]
}

@test "Code:shellcheck" {
	program=shellcheck
	code "$program"
	[ -f Setup.hs ]
	[ "$(basename "$PWD")" = "$program" ]

	# Check for broken links
	[[ -z $(find . -mindepth 1 -maxdepth 1 -type l ! -exec test -e {} \; -print) ]]
}

@test "Code:vpnks" {
	program=vpnks
	code "$program"
	[ -f README.md ]
	[ "$(basename "$PWD")" = "$program" ]

	# Check for broken links
	[[ -z $(find . -mindepth 1 -maxdepth 1 -type l ! -exec test -e {} \; -print) ]]
}

@test "Code:asdfasdfasdf" {
	program=asdfasdf
	run code "$program"
	[ $status = 2 ]
	[ "$output" = "Program '$program' not found in repos" ]
}

@test "Code: No connection" {
	route=$(ip route | grep -io "default via .* dev .*" || true)
	[ "$route" ] && eval sudo ip route delete $route
	sleep 2
	run code make
	[ $status != 0 ]
	[ "$(basename "$PWD")" != make ]
	echo "$output" | grep -qi error
	[ -n "$route" ] && eval sudo ip route add $route || true
}

@test "Code: Different destination" {
	mkdir dest
	code vpnks dest
	[ -f README.md ]
	[ "$(basename "$PWD")" = vpnks ]
	dname="$(dirname "$PWD")"
	[ "$(basename "$dname")" = dest ]
}

@test "Code: no checks" {
	run code --no-checks vpnks
	[ $status = 0 ]
	echo "$output" | grep -q 'Skipping all source file integrity checks'
	run bash -c 'echo "$output" | grep -q "Validating source files with"'
	[ $status = 1 ]
}
