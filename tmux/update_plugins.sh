tmuxdir="$HOME/.tmux.d"
[ -n "$TMUX_DIR" ] && tmuxdir="$TMUXDIR"
mkdir -p "$tmuxdir/plugins"

if ! hash git 2>/dev/null; then
	echo "Err: Git is not installed" >&2
	exit 1
fi

pushd . >/dev/null
cd "$tmuxdir/plugins"

if ! [ -d tmux-yank ]; then
	git clone https://github.com/tmux-plugins/tmux-yank.git
else
	[ -d tmux-yank/.git ] && git --git-dir=tmux-yank/.git pull
fi

popd >/dev/null
