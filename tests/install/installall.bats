#!/usr/bin/env bats

load functions

@test "Install all" {
	run uninstall
	run ../install.sh -y -d
	[ "$status" = 0 ]
}

@test "Bash config" {
	hash bash 2>/dev/null
	for file in ../bash/.*; do 
		[ -f $file ] && diff $file "$HOME/$(basename $file)" >/dev/null 2>&1
	done
}

@test "Cmus config" {
	hash cmus 2>/dev/null
	diff ../cmus/rc "$HOME/.config/cmus/rc" >/dev/null
}

@test "ctags config" {
	hash ctags 2>/dev/null
	diff ../ctags/.ctags "$HOME/.ctags" >/dev/null 2>&1
}

@test "emacs config" {
	hash emacs 2>/dev/null
	diff ../emacs/.emacs "$HOME/.emacs" >/dev/null
	for file in ../emacs/.emacs.d/*; do
		diff $file "$HOME/.emacs.d/$(basename $file)" >/dev/null
	done
}

@test "i3 config" {
	hash i3 2>/dev/null
	hash i3status 2>/dev/null
	hash dmenu 2>/dev/null
	hash urxvt 2>/dev/null || hash rxvt 2>/dev/null || hash rxvt-unicode 2>/dev/null

	diff ../i3/config "$HOME/.config/i3/config" >/dev/null 2>&1
	local copy=false
	for file in ../i3/i3status*; do 
		run diff "$file" "$HOME/.config/i3status/i3status.conf" >/dev/null 2>&1
		if [ $status = 0 ]; then
			copy=true
			break
		fi
	done
	$copy
}

@test "nano config" {
	hash nano 2>/dev/null
	diff ../nano/.nanorc "$HOME/.nanorc" >/dev/null 2>&1
}

@test "lemonbar config" {
	hash lemonbar 2>/dev/null
	ls ~/.fonts/misc/terminusicons2mono.bdf 2>/dev/null
	for file in ../lemonbar/*; do
		diff $file "$HOME/.config/lemonbar/$(basename $file)" 2>/dev/null
	done
}

@test "neovim config" {
	hash nvim 2>/dev/null
	for file in ../neovim/*; do
		diff $file "$HOME/.config/nvim/$(basename $file)" 2>/dev/null
	done
}


@test "powerline config" {
	hash powerline 2>/dev/null
	diff -r ../powerline "$HOME/.config/powerline" >/dev/null 2>&1
}


@test "ranger config" {
	hash ranger 2>/dev/null
	[ -f "$HOME/.config/ranger/rc.conf" ]
	diff ../ranger/rc.conf "$HOME/.config/ranger/rc.conf" >/dev/null 2>&1
}

@test "tmux config" {
	hash tmux 2>/dev/null
	diff ../tmux/.tmux.conf "$HOME/.tmux.conf" >/dev/null
}

@test "vim config" {
	hash vim 2>/dev/null
	diff ../vim/.vimrc "$HOME/.vimrc" >/dev/null 2>&1
	[ -z "$(diff -r ../vim/.vim "$HOME/.vim" | grep ../vim/.vim)" ]
}

@test "X config" {
	for file in ../X/.*; do
		[ -f $file ] && diff $file "$HOME/$(basename $file)" >/dev/null 2>&1
	done
}
