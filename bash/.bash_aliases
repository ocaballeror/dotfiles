# Some ls aliases
alias ls='ls --color=auto'
alias s='ls -CF'
alias l='ls -CF'
alias sl='ls'
alias lsw='ls'
alias lsç='ls'
alias ls7='ls'
alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -lhA'
alias llt='ls -lht'

# List only regular and special files (no directories)
alias lsf='files=""; for file in $(find . -maxdepth 1 ! -iname ".*"); do [ ! -d $file ] && files+="$(basename $file) "; done; ls $files; unset files'
alias lsfa='files=""; for file in $(find . -maxdepth 1); do [ ! -d $file ] && files+="$(basename $file) "; done; ls $files; unset files'

#List only directories
alias lsd='dirs=""; for dir in $(find . -mindepth 1 -maxdepth 1 -type d -a ! -iname ".*"); do dirs+="$(basename $dir) "; done; ls -d $dirs; unset dirs'
alias lsda='dirs=""; for dir in $(find . -mindepth 1 -maxdepth 1 -type d); do dirs+="$(basename $dir) "; done; ls -d $dirs; unset dirs'

# And assume we got permission to reboot without password
alias reboot='sudo reboot now'
alias shutdown='sudo shutdown now'
alias poweroff='sudo poweroff'

# And some custom aliases too
alias :q='exit'
alias :wq='exit'
alias ,,='cd ..'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias .......='cd ../../../../../../'
alias ........='cd ../../../../../../../'
alias .3='...'
alias .4='....'
alias .5='.....'
alias .6='......'
alias .7='.......'
alias .8='........'
alias act='source .venv/bin/activate'
alias adoc='ansible-doc -t module'
alias alert='notify-send "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias aliases='$EDITOR $HOME/.bash_aliases'
alias ax='chmod a+x'
alias bat='battery'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0| grep -E "state|time\ to\ full|percentage"'
alias bashrc='$EDITOR $HOME/.bashrc'
alias be='bundle exec'
alias bluetoothrec='sudo obexpushd -B23 -o /srv/bluetooth -n'
alias cde='cd'
alias cef='conda info --envs'
alias cl='fc -e -|pbcopy' # Copy the output of last command to clipboard
alias clean='sudo pacman -Scc; sudo pacman -Rns $(pacman -Qqtd); sudo pacman-optimize; rmshit'
alias clera='clear'
alias clipc='xsel --clipboard <'
alias clipp='xsel --clipboard >>'
alias cmusrc='$EDITOR $HOME/.config/cmus/rc'
alias cp='cp -v'
alias customs='$EDITOR $HOME/.bash_customs'
alias dc='docker-compose'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcdu='docker-compose down --volumes --remove-orphans && docker-compose up -d'
alias dd='sudo dd status=progress bs=512M'
alias diff='diff -EZ --color=auto'
alias emacsconf='emacs ~/.emacs &'
alias errcho='>&2 echo'
# alias fixup='git cm -a --fixup "$(git log --invert-grep --grep=fixup --pretty=oneline | head -1 | cut -d" " -f1)"'
alias fixup='git cm -m "fixup! $(git --no-pager log --pretty=%B | head -1 | sed "s/^fixup! //")"'
alias fixupa='git cm -am "fixup! $(git --no-pager log --pretty=%B | head -1 | sed "s/^fixup! //")"'
alias functions='$EDITOR ~/.bash_functions'
alias g++='g++ -std=c++14'
alias gitconfig='$EDITOR ~/.gitconfig'
alias gi='git'
alias gitk='gitk --all'
alias giit='git'
alias giot='git'
alias gitp='git'
alias gitt='git'
alias git4='git'
alias git5='git'
alias gti='git'
alias qgit='git'
alias grep='grep --color=auto -I --exclude-dir={.tox,.git,.ipynb_checkpoints} --exclude=.tags'
alias grpe='grep'
alias hask='ghci'
alias haskell='ghci'
alias hosts='sudo $EDITOR /etc/hosts'
alias i3conf='i3config'
alias i3config='[ -f $HOME/.config/i3/config ] && $EDITOR $HOME/.config/i3/config || echo "i3 config not found"'
alias i3stconf='i3statusconf'
alias i3statusconf='stconf=$HOME/.config/i3status/i3status.conf; [ ! -f $stconf ] && stconf=$HOME/.config/i3/i3status.conf; [ -f $stconf ] && $EDITOR $stconf'
alias ipa='ip address'
alias it='git'
alias ivm='vim'
alias j=''
alias jj=''
alias jjj=''
alias jnb='jupyter notebook'
alias json='python -m json.tool'
alias k='gitk --all &'
alias lyrics='lyricfetch'
alias lock='i3lock-fancy'
alias lslbk='lsblk'
alias less='less -r -i'
alias mc='molecule'
alias mem='free -mlt'
alias mdkir='mkdir'
alias mkidr='mkdir'
alias mkdir='mkdir -p'
alias mount='sudo mount'
alias mroe='more'
alias mv='mv -v'
alias mydu='du -hcs .[!.]* * 2> /dev/null | sort -hr | more'
alias mydu2='du -hcs .[!.]* */* 2> /dev/null | sort -hr | more'
alias mydu3='du -hcs .[!.]* */*/* 2> /dev/null | sort -hr | more'
alias mydu4='du -hcs .[!.]* */*/*/* 2> /dev/null | sort -hr | more'
alias mydu5='du -hcs .[!.]* */*/*/*/* 2> /dev/null | sort -hr | more'
alias n='sudo netstat -ntlp'
alias nvimrc='$EDITOR ~/.config/nvim/init.vim'
alias nvimdiff='nvim -d'
alias ogg='ffmpeg -c:a libvorbis -b:a 256k guitar.oga -i '
alias pak='pulseaudio -k && pulseaudio'
alias pkill='pkill -e'
alias ppi='pipenv install --dev'
alias ppp='pipenv run pytest -vv'
alias pppw='ppw'
alias ppu='pipenv --rm; pipenv install --dev && pipenv run pip install black flake8 ptpython pynvim python-lsp-server pylsp-mypy'
alias ppw='watchexec -e py -- pipenv run pytest -rs -vv --sw'
alias prompt='$EDITOR ~/.bash_prompt'
alias pvlibs='cd $(pipenv run which python 2>/dev/null | rev | cut -d/ -f3- |rev)/lib/python*/site-packages'
alias py='python'
alias py2='python2'
alias py3='python3'
alias pylibs='cd $(which python 2>/dev/null | rev | cut -d/ -f3- |rev)/lib/python*/site-packages'
alias pytests='pytest'
alias pythontools='eval $(cef | grep "^[a-zA-Z]" | cut -d " " -f1 | grep -v "^base$" | xargs -I % echo "conda activate %; pip install -U pip ptpython jedi pynvim flake8 pylint;"); conda deactivate'
alias quit='exit'
alias quti='quit'
alias reprompt='export PS1=$(echo $PS1 | grep -oP "\\(.*\\) \\K.*")'
alias reswap='swpfile=$(swapon | tail -1 | cut -d" " -f1); sudo swapoff $swpfile; sudo swapon $swpfile; unset swpfile'
alias sa='conda activate'
alias sa.='conda activate $(basename $PWD)'
alias sd='conda deactivate'
alias sduo='sudo'
alias sulb='subl'
alias suod='sudo'
alias swipl.='swipl'
alias switchlight='echo -e "\033]11;#ffffff\007\033]10;#000000\007\033]12;#000000\007"; reload'
alias switchdark='echo -e "\033]11;#242424\007\033]10;#ffffff\007\033]12;#ffffff\007"; reload'
alias systemclt='systemctl'
alias tmuxconf='$EDITOR ~/.tmux.conf'
alias touchpad='xinput disable $(xinput list | grep  -Eio "touchpad.*id=[0-9]+" | head -1 | cut -d= -f2)'
alias touchpad2='xinput enable $(xinput list | grep  -Eio "touchpad.*id=[0-9]+" | head -1 | cut -d= -f2)'
alias trash='gio trash'
alias tree='tree -C'
alias ttox='tox -e py36 -- -n$(nproc)'
alias tttox='tox -e lint,py36 -- -n$(nproc)'
alias umount='sudo umount'
alias update='sudo pacman -Syy; yaourt -Syu --devel --aur --noconfirm'
alias fullupdate='yaourt -Syu --devel --aur --noconfirm && yaourt -Syu --devel --aur'
alias venv='rm -rf .venv && virtualenv .venv && source .venv/bin/activate && pip install black flake8 ptpython pynvim python-lsp-server pylsp-mypy && { [ ! -f requirements.txt ] || pip install -r requirements.txt; }'
alias vi='vim'
alias vimm='vim'
alias vmi='vim'
alias vimrc='$EDITOR ~/.vimrc'
alias watchexec='watchexec -r -c'
alias wireshark='sudo wireshark-gtk > /dev/null 2> /dev/null &'
alias ytmp3='youtube-dl -x --audio-format mp3 --audio-quality 0'
alias zshrc='$EDITOR ~/.zshrc'

hash htop 2>/dev/null && alias top='htop'
hash ptpython 2>/dev/null && alias py='ptpython'
