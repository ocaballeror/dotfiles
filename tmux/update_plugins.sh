tmuxdir="$HOME/.tmux"
[ -n "$TMUX_DIR" ] && tmuxdir="$TMUXDIR"

[ ! -d "$tmuxdir/plugins" ] && mkdir -p "$tmuxdir/plugins"

if ! hash git 2>/dev/null; then
	echo "Err: Git is not installed" >&2
	exit 1
fi

pushd . >/dev/null
cd "$tmuxdir/plugins"

git clone https://github.com/tmux-plugins/tmux-yank.git

popd >/dev/null
