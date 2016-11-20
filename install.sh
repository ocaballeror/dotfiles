thisdir=$(dirname $(readlink -f $(basename $0)))

#First off, the general $HOME based conf files
for folder in bash vim tmux; do
	for file in "$thisdir"/"$folder"/.* "$thisdir"/"$folder"/*; do 
		[ -f "$file" ] && cp "$file" "$HOME"
	done
done
unset file

#And now the customs

#Restore vim plugins
source vim/pathogen.sh

#Check package managers and install program $1 if it's not installed. The rest of the 
#arguments are other possible names for this program
install() {
	for name in "$@"; do #Check if the program is installed under any of the names provided
		if hash $name 2>/dev/null; then
			return 0; #If it's already installed there's nothing to do here
		fi
	done

	echo -n "$1 is not installed. Do you want to try and install it? (Y/n): "
	read -n1 opt
	if [ "$opt" != "n" ]; then
		if [ -f /etc/lsb-release ]; then
			os="$(lsb_release)"
			if [ "$os" = Arch ]; then
				install="sudo pacman -Syy && sudo pacman -S"
			elif [ "$os" = Ubuntu ] || [ "$os" = "elementary OS" ]; then
				install="sudo apt-get update && sudo apt-get install -y"
			else
				echo "Could not find the right package manager for your distribution. Please
				install $1 manually"
			fi
		elif [ -f /etc/debian_version ]; then
			install="sudo apt-get update && sudo apt-get install -y"
		elif [ -f /etc/fedora-release ]; then
			install="sudo dnf install"
		else
			echo "Could not find the right package manager for your distribution. Please install
			$1 manually"
		fi

		if ! eval "$install" "$1"; then
			echo "Unknown error while installing $1. Please do it manually"
		fi
	fi

}

install "powerline" "powerline-status" "python-powerline" "python2-powerline" "python-powerline-git" "python2-powerline-git"
install "tmux" "tmux-git"
install "pip2" "pip"
sudo pip2 install powerline-mem-segment

#Copy the powerline configuration files
[ ! -d $HOME/.config ] && mkdir -p $HOME/.config
cp -r "$thisdir"/powerline $HOME/.config/


#Reload everything
. $HOME/.bashrc
vim -c ":Helptags | :q"

if [ "$1" = "-r" ] || [ "$1" = "--root" ]; then
	for file in .bashrc .bash_aliases .bash_functions .tmux.conf .vimrc; do
		sudo rm /root/$file 2>/dev/null
		sudo ln -s $HOME/$file .
	done
fi
