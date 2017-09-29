#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

hash gdfs 2>/dev/null || { echo "Gdfs is not installed"; exit 1; }

setup(){
	if ! ping -c1 www.google.com >/dev/null 2>&1; then
		skip "No internet connection"
	fi
}

@test "Drive" {
	drive
	grep -qs "$HOME/Drive" /proc/mounts
	sudo fusermount -uz "$HOME/Drive"
	sleep .2
	sudo pkill -9 gdfs
}

@test "Drive kill" {
	local created=false
	[ ! -d "$HOME/Drive" ] && { created=true; mkdir "$HOME/Drive"; }
	sudo gdfs -o big_writes -o allow_other "$HOME/.config/gdfs/gdfs.auth"  "$HOME/Drive"
	grep -qs "$HOME/Drive" /proc/mounts
	run drive -k
	sleep 1
	run grep "$HOME/Drive" /proc/mounts
	[ $status = 1 ]

	if $created; then rmdir --no-fail-on-empty "$HOME/Drive"; fi
}

@test "Drive with no caching" {
	drive -n
	[ -z "$(ps aux | grep "find $HOME/Drive" | grep -v grep)" ]
	sleep 1
	grep -qs "$HOME/Drive" /proc/mounts

	run drive -k
}

@test "Drive on a different mount point" {
	# skip "This is not even implemented"
	[ 1 = 0 ]
	cwd="$(pwd)"
	temp="$(mktemp -d)"
	cd "$temp"

	mkdir drive
	drive drive
	grep -qs "$temp/drive" /proc/mounts
	
	drive -k
	cd "$cwd"
	rm -rf "$temp"
}
