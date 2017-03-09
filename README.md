# dotfiles

This is a simple repo with all the dotfiles I use everyday on my systems.

You're free to see, use, copy and do whatever you want with the code in this repo


## Install
An installation script called `install.sh` is provided. Just run:
```
./install.sh
```
to copy every file to their respective directory. Passing program names as arguments will make the script install only the dotfiles for those programs:
```
# Install only bash, vim and powerline's dotfiles
./install.sh bash vim powerline
```
Alternatively, if you want to install every dotfile but one or two, use the -x option:
```
#Install everything except for tmux
./install.sh -x tmux
```
Run the script with -h to see all the available options.

Also, don't worry if any of the programs is not currently installed, the script will try hard to install them using your distro's repositories or git. This makes deployment of my entire setup very easy for new machines or fresh installs.

### WARNING
The installation script has been tested under bash on Ubuntu, Debian and ArchLinux,  and should be compatible with any decently modern version of those. Compatibility with other shells such as ksh, zsh, dash etc. hasn't been properly tested, and it could have some unexpected behaviour, so run it at your own risk if bash is not available in your system.

Also, compatibility with OSX shouldn't be expected at all. I don't have a Mac, I don't intend to buy one and VMs for it run terribly slow, so I couldn't even test it if I wanted. Feel free to read any code and adapt it to your system, though.
