#!/usr/bin/env bats

load functions

@test "Offline" {
	../../install.sh -o
}

@test "No Root" {
	../../install.sh -n
}

@test "No installations" {
	../../install.sh -i
}

@test "Install vim with no plugins" {
	run pacapt -Rn --noconfirm vim
	run rm -rf "$HOME/.vim"
	run rm "$HOME/.vimrc"

	../../install.sh -y -p vim

	diff ../../vim/.vimrc "$HOME/.vimrc" >/dev/null 2>&1
	[ ! -d "$HOME/.vim/bundle" ] || [ $(ls "$HOME/.vim/bundle" | wc -l) = 0 ]
	[ -z "$(diff -r ../../vim/.vim "$HOME/.vim" | grep ../../vim/.vim)" ]
}

@test "Install vim and neovim" {
	run pacapt -Rn --noconfirm vim neovim
	run rm -rf "$HOME/.vimrc" "$HOME/.vim" "$HOME/.config/nvim"

	../../install.sh -y vim neovim

	for d in autoload backup bundle ftplugin swp undo; do
		if [ -d "$HOME/.vim/$d" ] && [ ! -L "$HOME/.vim/$d" ]; then
			[ -d "$HOME/.config/nvim/$d" ] && [ -L "$HOME/.config/nvim/$d" ]
		fi
	done
}

@test "Install neovim after vim" {
	run pacapt -Rn --noconfirm vim neovim
	run rm -rf "$HOME/.vimrc" "$HOME/.vim" "$HOME/.config/nvim"

	../../install.sh -y vim
	../../install.sh -y neovim

	for d in autoload backup bundle ftplugin swp undo; do
		if [ -d "$HOME/.vim/$d" ] && [ ! -L "$HOME/.vim/$d" ]; then
			[ -d "$HOME/.config/nvim/$d" ] && [ -L "$HOME/.config/nvim/$d" ]
		fi
	done
}

@test "Install vim after neovim" {
	run pacapt -Rn --noconfirm vim neovim
	run rm -rf "$HOME/.vimrc" "$HOME/.vim" "$HOME/.config/nvim"

	../../install.sh -y neovim
	../../install.sh -y vim

	for d in autoload backup bundle ftplugin swp undo; do
		if [ -d "$HOME/.config/nvim/$d" ] && [ ! -L "$HOME/.config/nvim/$d" ]; then
			[ -d "$HOME/.vim/$d" ] && [ -L "$HOME/.vim/$d" ]
		fi
	done
}
