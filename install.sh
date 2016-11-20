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
