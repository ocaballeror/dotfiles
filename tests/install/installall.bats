#!/usr/bin/env bats

load functions

setup() {
	program="$(echo "$BATS_TEST_DESCRIPTION" | awk '{print $2}')"
	../../install.sh -y -d "$program"
	if [ "$(echo "$BATS_TEST_DESCRIPTION" | awk '{print $1}')" = "Install" ]; then
		hash "$program"
	fi
}

@test "Install bash" {
	for file in ../../bash/.*; do
		[ -f $file ] && diff $file "$HOME/$(basename $file)"
	done
}

@test "Install cmus" {
	diff ../../cmus/rc "$HOME/.config/cmus/rc"
}

@test "Install ctags" {
	diff ../../ctags/.ctags "$HOME/.ctags"
}

@test "Install emacs" {
	diff ../../emacs/.emacs "$HOME/.emacs"
	for file in ../../emacs/.emacs.d/*; do
		diff $file "$HOME/.emacs.d/$(basename $file)"
	done
}

@test "Install i3" {
	hash i3status
	hash dmenu
	hash urxvt || hash rxvt || hash rxvt-unicode

	diff ../../i3/config "$HOME/.config/i3/config"
	local copy=false
	for file in ../../i3/i3status*; do
		run diff "$file" "$HOME/.config/i3status/i3status.conf"
		if [ $status = 0 ]; then
			copy=true
			break
		fi
	done
	$copy
}

@test "Install nano" {
	diff ../../nano/.nanorc "$HOME/.nanorc"
}

@test "Install mpd" {
	[ -d "$HOME/.config/mpd" ]
	for file in ../../mpd/*; do
		diff $file "$HOME/.config/mpd/$(basename "$file")"
	done
}

@test "Install lemonbar" {
	[ -f "$HOME/.fonts/misc/terminusicons2mono.bdf" ]
	for file in ../../lemonbar/*; do
		diff $file "$HOME/.config/lemonbar/$(basename $file)"
	done
}

@test "Install ncmpcpp" {
	[ -d "$HOME/.config/ncmpcpp" ]
	for file in ../../ncmpcpp/*; do
		diff $file "$HOME/.config/ncmpcpp/$(basename "$file")"
	done
}

@test "Install nvim" {
	diff ../../neovim/init.vim "$HOME/.config/nvim/init.vim"
	for folder in autoload bundle ftplugin; do
		[ -d "$HOME/.config/nvim/$folder" ]
	done
	for folder in autoload bundle ftplugin; do
		[ "$(ls "$HOME/.config/nvim/$folder" | wc -l)" -gt 0 ]
	done
}

@test "Install ncmpcpp" {
	[ -d "$HOME/.config/ncmpcpp" ]
	for file in ../../ncmpcpp/*; do
		diff $file "$HOME/.config/ncmpcpp/$(basename "$file")"
	done
}

@test "Install powerline" {
	diff -r ../../powerline "$HOME/.config/powerline"
}


@test "Install ranger" {
	[ -f "$HOME/.config/ranger/rc.conf" ]
	diff ../../ranger/rc.conf "$HOME/.config/ranger/rc.conf"
}

@test "Install tmux" {
	diff ../../tmux/.tmux.conf "$HOME/.tmux.conf"
}

@test "Install vim" {
	diff ../../vim/.vimrc "$HOME/.vimrc"
	[ -z "$(diff -r ../../vim/.vim "$HOME/.vim" | grep ../../vim/.vim)" ]

	for folder in autoload bundle ftplugin; do
		[ -d "$HOME/.vim/$folder" ]
	done
	for folder in autoload bundle ftplugin; do
		[ "$(ls "$HOME/.vim/$folder" | wc -l)" -gt 0 ]
	done
}

@test "Configure X" {
	for file in ../../X/.*; do
		[ -f $file ] && diff $file "$HOME/$(basename $file)"
	done
}
