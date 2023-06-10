here=$(dirname "$(readlink -f "$0")")
temp=$(mktemp -d)
config=${XDG_CONFIG_HOME:-~/.config}

errcho() {
    >&2 echo "$@"
}

pacapt(){
    # We'll use the awesome pacapt script from https://github.com/icy/pacapt to install packages on any distro (even OSX!)
    if [ ! -f "$temp/pacapt" ]; then
        curl -sL "https://github.com/icy/pacapt/raw/ng/pacapt" -o "$temp/pacapt" || return 127
        chmod +x "$temp/pacapt"
    fi

    sudo "$temp/pacapt" "$@"
}

install() {
    for name in "$@"; do
        pacapt "$name" || continue
        break
    done
    ret=$?
    [ $ret = 0 ] || { errcho "Cannot install under any of the aliases: $@"; return $ret; }
}

depack() {
    install ack || return $?
    cp "$here/ack/.ackrc" ~
}

depalacritty() {
    install alacritty || return $?
    cp -r "$here/alacritty" "$config"
}

depbash() {
    cp -r "$here/bash/".[^.]* ~
}

depctags() {
    install ctags || return $?
    mkdir -p ~/.ctags.d
    cp -r "$here/ctags/.ctags" ~/.ctags.d/conf.ctags
}

depgit() {
    install git || return $?
    cp "$here/git/.gitconfig" ~
    mkdir -p "$config/git"
    cp "$here/git/ignore" "$config/git/ignore"
}

depi3() {
    install i3 || return $?
    deprofi
    deppolybar

    mkdir -p "$config/i3"
    cp -r "$here/i3/scripts" "$config/i3"
    cp -r "$here/i3/config" "$config/i3"

    # i3status is really just an optional fallback to polybar for us
    if install i3status; then
        mkdir -p "$config/i3status"
        cp "$here/i3status.conf" "$config/i3status"
    fi
}

depjupyter() {
    # will not globally install jupyter. should be handled by each venv
    mkdir -p ~/.jupyter/nbconfig
    cp "$here/jupyter/notebook.json" ~/.jupyter/nbconfig
}

depnano() {
    install nano || return $?
    cp "$here/nano/.nanorc" ~
}

depneovim() {
    install nvim neovim || return $?
    depctags
    cp -r "$here/neovim" "$config/nvim"
}

deppolybar() {
    install polybar || return $?
    cp -r "$here/polybar" "$config"
}

depptpython() {
    install ptpython || return $?
    cp -r "$here/ptpython" "$config"
}

depranger() {
    install ranger || return $?
    cp -r "$here/ranger" "$config"
}

deprofi() {
    install rofi || return $?
    cp -r "$here/rofi" "$config"
}

deptmux() {
    install tmux || return $?
    cp -r "$here/tmux/.tmux.conf" ~
    mkdir -p ~/.tmux
    cp -r "$here/tmux/"* ~/.tmux
    source ~/.tmux/update_plugins.sh
}

depvim() {
    install vim || return $?
    cp -r "$here/vim/.vim" "$here/vim/.vimrc" ~
}

reqs=( sudo curl )
for name in $reqs; do
    if ! hash $name 2>/dev/null; then
        errcho "Requirement not installed: $name"
        errcho "Please install all required tools: ${reqs[@]}"
        exit 1
    fi
done

if [ $# = 0 ]; then
    for name in $(declare -F | sed 's/declare -f //' | grep '^dep'); do
        echo "Deploying ${name#dep}"
        ( $name )
    done
else
    while [ $# -gt 0 ]; do
        echo "Deploying $1"
        ( $1 )
        shift
    done
fi
