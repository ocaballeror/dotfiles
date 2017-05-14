uninstall() {
	local list=""
	for program in cmus ctags emacs i3 powerline ranger tmux vim; do
		sudo pacapt -Rn $program
	done
	
	return 0
}

pacapt(){
	if [ ! -f "$BATS_TMPDIR/pacapt" ]; then
		#wget -qO pacapt https://github.com/icy/pacapt/raw/ng/pacapt 
		curl -sL https://github.com/icy/pacapt/raw/ng/pacapt -o "$tempdir/pacapt"
		[ "$?" = 0 ]
	fi

	chmod +x "$BATS_TMPDIR/pacapt"
	sudo "$BATS_TMPDIR/pacapt" $*
}
