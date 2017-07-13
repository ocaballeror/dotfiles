# And them some ls aliases
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
# List only regular and special files (no directories)
alias lsf='files=""; for file in $(find . -maxdepth 1 ! -iname ".*"); do [ ! -d $file ] && files+="$(basename $file) "; done; ls $files; unset files'
alias lsfa='files=""; for file in $(find . -maxdepth 1); do [ ! -d $file ] && files+="$(basename $file) "; done; ls $files; unset files'
#List only directories
alias lsd='dirs=""; for dir in $(find . -mindepth 1 -maxdepth 1 -type d -a ! -iname ".*"); do dirs+="$(basename $dir) "; done; ls -d $dirs; unset dirs'
alias lsda='dirs=""; for dir in $(find . -mindepth 1 -maxdepth 1 -type d); do dirs+="$(basename $dir) "; done; ls -d $dirs; unset dirs'

# Always get colorized grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

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
alias 3.='.3'
alias 4.='.4'
alias 5.='.5'
alias 6.='.6'
alias 7.='.7'
alias 8.='.8'
alias aliases="$EDITOR $HOME/.bash_aliases"
alias ax='chmod a+x'
alias android='/usr/share/android-studio/bin/studio.sh > /dev/null 2> /dev/null &'
alias bat='battery'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0| grep -E "state|time\ to\ full|percentage"'
alias bashrc='$EDITOR $HOME/.bashrc'
alias c='cd'
alias cde='cd'
alias cl='fc -e -|pbcopy' # Copy the output of last command to clipboard
alias clean='sudo pacman -Scc; sudo pacman -Rns $(pacman -Qqtd); sudo pacman-optimize; rmshit'
alias clera='clear'
alias clipcopy='xsel --clipboard <'
alias clippaste='xsel --clipboard >>'
alias clipcp='clipcopy'
alias clipc='clipcp'
alias clipp='clippaste'
alias cmusrc='$EDITOR $HOME/.config/cmus/rc'
alias connection='ping -c 3 www.google.com'
alias cp='cp -v'
alias dd='sudo dd status=progress bs=512M'
alias depth='echo $(($(find . | tr -cd "/\n" | sort | tail -1 | wc -c) -1))'
alias diff='diff -EZ --color=auto'
alias eclipse='/opt/eclipse/eclipse > /dev/null 2> /dev/null &'
alias emacsconf='emacs ~/.emacs &'
alias errcho='>&2 echo'
alias fucking='sudo'
alias functions="$EDITOR ~/.bash_functions"
alias g++='g++ -std=c++14'
alias hask='ghci'
alias haskell='ghci'
alias helloworld='printf "#include <stdio.h>\n\nint main() {\n\tprintf(\"Hello world\\\n\");\n\treturn 0;\n}\n" > hello.c'
alias indigo='/opt/eclipse-indigo/eclipse > /dev/null 2> /dev/null &'
alias i3conf='i3config'
alias i3config="[ -f $HOME/.config/i3/config ] && $EDITOR $HOME/.config/i3/config || echo 'i3 config not found'"
alias i3statusconf="stconf=$HOME/.config/i3status/i3status.conf; [ ! -f $stconf ] && stconf=$HOME/.config/i3/i3status.conf; [ -f $stconf ] && $EDITOR $stconf"
alias ipa='ip address'
alias light='light_theme'
alias light_theme='source ~/Scripts/.light_theme.sh'
alias lock='i3lock-fancy'
alias lslbk='lsblk'
alias less='less -r'                          # raw control characters
alias mdkir='mkdir'
alias mkidr='mkdir'
alias mem='free -mlt'
alias mergedots="for name in .bashrc .bash_aliases .bash_functions .vimrc .tmux.conf; do comp ~/$name ~/Stuff/dotfiles/*/$name; done"
alias mkdir='mkdir -p'
alias monitor='xrandr --output DP-0 --auto --primary --right-of DVI-D-0; source ~/.fehbg; pidof i3 >/dev/null && i3-msg restart'
alias mount='sudo mount'
alias mp3='ffmpeg -codec:a libmp3lame -qscale:a 0 -b:a 320k out.mp3 -i'
alias mroe='more'
alias mv='mv -v'
alias mydu='du -hcs .[!.]* * 2> /dev/null | sort -hr | more'
alias mydu2='du -hcs .[!.]* */* 2> /dev/null | sort -hr | more'
alias mydu3='du -hcs .[!.]* */*/* 2> /dev/null | sort -hr | more'
alias mydu4='du -hcs .[!.]* */*/*/* 2> /dev/null | sort -hr | more'
alias mydu5='du -hcs .[!.]* */*/*/*/* 2> /dev/null | sort -hr | more'
alias ny='vpn US_New_York_City'
alias pkill='pkill -e'
alias py='python'
alias py2='python2'
alias py3='python3'
alias quit='exit'
alias quti='quit'
alias reload="source $HOME/.bashrc; [ -f $HOME/.Xresources ] && xrdb $HOME/.Xresources"
alias sduo='sudo'
alias sever='server'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test1000.zip'
alias sql='mysql -u root -p'
alias subl='/opt/sublime_text_3/sublime_text'
alias sulb='subl'
alias suod='sudo'
alias swipl.='swipl'
alias switchlight='echo -e "\033]11;#ffffff\007\033]10;#000000\007\033]12;#000000\007"'
alias switchdark='echo -e "\033]11;#242424\007\033]10;#ffffff\007\033]12;#ffffff\007"'
alias systemclt='systemctl'
alias tmuxconf="$EDITOR ~/.tmux.conf"
alias trash='gvfs-trash'
alias tree='tree -C'
alias umount='sudo umount'
#alias update='sudo apt-get clean && sudo apt-get update && sudo apt-get autoremove && sudo apt-get upgrade'
alias update='sudo pacman -Syy; yaourt -Syu --devel --aur --noconfirm'
alias fullupdate='yaourt -Syu --devel --aur --noconfirm && yaourt -Syu --devel --aur'
alias vimrc="$EDITOR ~/.vimrc"
alias watchbat='while true; do bat; sleep 1; clear; done'
alias watchip='watch "wget https://ipinfo.io/ip -qO -"'
alias whence='type -a'                        # where, of a sort
alias wireshark='sudo wireshark-gtk > /dev/null 2> /dev/null &'
alias whatsapp='cd; virtualbox --startvm Android & >/dev/null 2>&1; firefox --new-tab web.whatsapp.com & >/dev/null 2>&1; builtin cd - >/dev/null 2>&1'
alias ytmp3='youtube-dl -x --audio-format mp3 --audio-quality 0'



# SADLY, I COULDN'T FIT THIS ONE INTO ONE LINE
vim_alias="vim"
if [ "$(vim --version | grep -Eo ".?clientserver" | cut -b1)" = "+" ]; then
	vim_alias+=" --servername '$(date '+%d-%m-%Y %H:%M:%S')'"
fi

launchsession=true
for arg in $@; do
	if [ ${arg:0:1} != "-" ]; then
		launchsession=false
		break;
	fi
done

if $launchession && [ -f .vimsession ]; then
	vim_alias+=" -S .vimsession"
fi
alias vim="$vim_alias"
