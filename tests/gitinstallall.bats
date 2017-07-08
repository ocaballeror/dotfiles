#!/usr/bin/env bats

load functions

@test "GitInstall all" {
	run uninstall
	run ../install.sh -y -d -g --override 
	[ "$status" = 0 ]
}

@test "Bash config" {
	hash bash
	for file in ../bash/.*; do 
		[ -f $file ] && diff $file "$HOME/$(basename $file)"
	done
}

@test "Cmus config" {
	hash cmus
	diff ../cmus/rc "$HOME/.config/cmus/rc" 
}

@test "ctags config" {
	hash ctags
	diff ../ctags/.ctags "$HOME/.ctags"
}

@test "emacs config" {
	hash emacs 2>/dev/null
	diff ../emacs/.emacs "$HOME/.emacs"
	for file in ../emacs/.emacs.d/*; do
		diff $file "$HOME/.emacs.d/$(basename $file)"
	done
}

@test "i3 config" {
	hash i3
	hash i3status
	hash dmenu
	hash urxvt || hash rxvt || hash rxvt-unicode 

	diff ../i3/config "$HOME/.config/i3/config"
	local copy=false
	for file in ../i3/i3status*; do 
		run diff "$file" "$HOME/.config/i3status/i3status.conf"
		if [ $status = 0 ]; then
			copy=true
			break
		fi
	done
	$copy
}

@test "nano config" {
	hash nano
	diff ../nano/.nanorc "$HOME/.nanorc" 
}

@test "mpd config" {
	hash mpd 2>/dev/null
	[ -d "$HOME/.config/mpd" ]
	for file in ../mpd/*; do
		diff $file "$HOME/.config/mpd/$(basename "$file")"	
	done
}

@test "lemonbar config" {
	hash lemonbar 
	[ -f "$HOME/.fonts/misc/terminusicons2mono.bdf" ]
	for file in ../lemonbar/*; do
		diff $file "$HOME/.config/lemonbar/$(basename $file)"
	done
}

@test "neovim config" {
	hash nvim 
	diff ../neovim/init.vim "$HOME/.config/nvim/init.vim"
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
	for file in ../ncmpcpp/*; do
		diff $file "$HOME/.config/ncmpcpp/$(basename "$file")"	
	done
}

@test "powerline config" {
	hash powerline 
	diff -r ../powerline "$HOME/.config/powerline" 
}


@test "ranger config" {
	hash ranger
	[ -f "$HOME/.config/ranger/rc.conf" ]
	diff ../ranger/rc.conf "$HOME/.config/ranger/rc.conf" 
}

@test "tmux config" {
	hash tmux
	
	diff ../tmux/.tmux.conf "$HOME/.tmux.conf"
}

@test "vim config" {
	hash vim
	diff ../vim/.vimrc "$HOME/.vimrc"
	[ -z "$(diff -r ../vim/.vim "$HOME/.vim" | grep ../vim/.vim)" ]

	for folder in autoload bundle ftplugin; do
		[ -d "$HOME/.vim/$folder" ]
	done
	for folder in autoload bundle ftplugin; do
		[ "$(ls "$HOME/.vim/$folder" | wc -l)" -gt 0 ]
	done
}

@test "X config" {
	for file in ../X/.*; do
		[ -f $file ] && diff $file "$HOME/$(basename $file)"
	done
}
