#!/usr/bin/env bats

load functions

@test "Offline" {
	run ../install.sh -o
}

@test "No Root" {
	run ../install.sh -n
}

@test "No installations" {
	run ../install.sh -i
}

@test "Install vim with no plugins" {
	run pacapt -Rn --noconfirm vim
	run rm -rf "$HOME/.vim"
	run rm "$HOME/.vimrc"

	run ../install.sh -y -p vim
	
	diff ../vim/.vimrc "$HOME/.vimrc" >/dev/null 2>&1
	[ ! -d "$HOME/.vim/bundle" ] || [ $(ls "$HOME/.vim/bundle" | wc -l) = 0 ]
	[ -z "$(diff -r ../vim/.vim "$HOME/.vim" | grep ../vim/.vim)" ]
}
