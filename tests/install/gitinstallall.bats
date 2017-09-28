#!/usr/bin/env bats

load functions

@test "GitInstall all" {
	run uninstall
	run ../../install.sh -y -d -g --override 
	[ "$status" = 0 ]
}

@test "Bash config" {
	hash bash 2>/dev/null
	for file in ../../bash/.bash*; do 
		if [ -f $file ] && [ "$(basename "$file")" != ".tags" ]; then
			cmp -s $file "$HOME/$(basename $file)"
		fi
	done
}

@test "Cmus config" {
	hash cmus 2>/dev/null
	diff ../../cmus/rc "$HOME/.config/cmus/rc" 
}

@test "ctags config" {
	hash ctags 2>/dev/null
	diff ../../ctags/.ctags "$HOME/.ctags"
}

@test "emacs config" {
	hash emacs 2>/dev/null
	diff ../../emacs/.emacs "$HOME/.emacs"
	for file in ../../emacs/.emacs.d/*; do
		diff $file "$HOME/.emacs.d/$(basename $file)"
	done
}

@test "i3 config" {
	hash i3 2>/dev/null
	hash i3status 2>/dev/null
	hash dmenu 2>/dev/null
	hash urxvt 2>/dev/null || hash rxvt 2>/dev/null || hash rxvt-unicode 2>/dev/null

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

@test "nano config" {
	hash nano 2>/dev/null
	diff ../../nano/.nanorc "$HOME/.nanorc" 
}

@test "mpd config" {
	hash mpd 2>/dev/null
	[ -d "$HOME/.config/mpd" ]
	for file in ../../mpd/*; do
		diff $file "$HOME/.config/mpd/$(basename "$file")"	
	done
}

@test "lemonbar config" {
	hash lemonbar  2>/dev/null
	[ -f "$HOME/.fonts/misc/terminusicons2mono.bdf" ]
	for file in ../../lemonbar/*; do
		diff $file "$HOME/.config/lemonbar/$(basename $file)"
	done
}

@test "neovim config" {
	hash nvim  2>/dev/null
	diff ../../neovim/init.vim "$HOME/.config/nvim/init.vim"
	for folder in autoload bundle ftplugin; do
		[ -d "$HOME/.config/nvim/$folder" ]
	done
	for folder in autoload bundle ftplugin; do
		[ "$(ls "$HOME/.config/nvim/$folder" | wc -l)" -gt 0 ]
	done
}

@test "ncmpcpp config" {
	hash ncmpcpp 2>/dev/null
	[ -d "$HOME/.config/ncmpcpp" ]
	for file in ../../ncmpcpp/*; do
		diff $file "$HOME/.config/ncmpcpp/$(basename "$file")"	
	done
}

@test "powerline config" {
	hash powerline  2>/dev/null
	diff -r ../../powerline "$HOME/.config/powerline" 
}


@test "ranger config" {
	hash ranger 2>/dev/null
	[ -f "$HOME/.config/ranger/rc.conf" ]
	diff ../../ranger/rc.conf "$HOME/.config/ranger/rc.conf" 
}

@test "tmux config" {
	hash tmux 2>/dev/null
	
	diff ../../tmux/.tmux.conf "$HOME/.tmux.conf"
}

@test "vim config" {
	hash vim 2>/dev/null
	diff ../../vim/.vimrc "$HOME/.vimrc"
	[ -z "$(diff -r ../../vim/.vim "$HOME/.vim" | grep ../../vim/.vim)" ]

	for folder in autoload bundle ftplugin; do
		[ -d "$HOME/.vim/$folder" ]
	done
	for folder in autoload bundle ftplugin; do
		[ "$(ls "$HOME/.vim/$folder" | wc -l)" -gt 0 ]
	done
}

@test "X config" {
	for file in ../../X/.*; do
		[ -f $file ] && diff $file "$HOME/$(basename $file)"
	done
}
