pacapt(){
	if [ ! -f "$BATS_TMPDIR/pacapt" ]; then
		#wget -qO pacapt https://github.com/icy/pacapt/raw/ng/pacapt
		curl -sL https://github.com/icy/pacapt/raw/ng/pacapt -o "$tempdir/pacapt"
		[ "$?" = 0 ]
	fi

	chmod +x "$BATS_TMPDIR/pacapt"
	sudo "$BATS_TMPDIR/pacapt" $*
}
