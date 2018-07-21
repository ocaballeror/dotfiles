#!/bin/bash

# A collection of little scripts that I find useful in my everyday unix life 
# Functions prepended with '_' are not meant to be used directly, and instead serve as auxiliary functions to others. They may have no parameters and little documentation because of this.

# Global return codes
#	0 - Everything went as planned
#	1 - There was an error in the arguments (unsufficient, mistyped...)
#	2 - Referenced files or directories do not exist
#	3 - Other

# TODO Create and use errcho, for God's sake

# Set brightness on my stupid laptop that doesn't seem to work with xbacklight for some reason
# Still requires root
brightness(){
	local usage="Usage: ${FUNCNAME[0]} <brightness>.
You can specify relative values using '+' and '-' signs before number and/or percentages appending '%' to the number. For example:

Set brightness to 300
${FUNCNAME[0]} 300

Set brightness to 50%
${FUNCNAME[0]} 50%

Increase brightness by 50
${FUNCNAME[0]} +50

Decrease brightness by 10%
${FUNCNAME[0]} -10%
"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local value=$1

	local relative=false
	local sign=""
	local percentage=false
	if [ ${1:0:1} = "+" ] || [ ${1:0:1} = "-" ]; then
		relative=true
		sign=${value:0:1}
		value=${value:1}
	fi

	local length=$((${#value} - 1))
	local lastpos=${value:$length}
	if [ $lastpos = "%" ]; then
		percentage=true	
		value=${value:0:$length}
	fi

	local re='^[0-9]*$'
	if ! [[ $value =~ $re ]]; then
		if [ $value != "max" ]; then
			echo "Err: '$value' is not a number"
			return 1
		fi
	fi
	
	local path="/sys/class/backlight/intel_backlight"
	[ ! -d $path ] && { echo "Err: Couldn't access path '$path'"; return 2; }
	for filename in max_brightness actual_brightness; do
		if [ ! -f $path/$filename ]; then
			echo "Err: Couldn't find file $filename"
			return 2
		fi
	done

	local bright maxb current
	maxb=$(cat $path/max_brightness)
	current=$(cat $path/actual_brightness)
	if $relative; then
		if $percentage; then
			bright=$(echo "scale=2; ($current $sign (($value*$maxb)/100))" | bc)
			bright=${bright%%.*}
		else
			bright=$(($current $sign $value))
		fi
	else
		if $percentage; then
			bright=$(echo "scale=2; ($value * $maxb) / 100" | bc)
			bright=${bright%%.*}
		else
			if [ $value = "max" ]; then
				bright=$maxb
			elif [ $value -gt $maxb ]; then
				echo "W: Brightness will be set to max brightness $maxb"
				bright=$maxb
			else
				bright=$value
			fi
		fi
	fi

	[ $bright = $current ] && return 0
	[ $bright -gt $maxb ]  && bright=$maxb
	[ $bright -lt 0 ]      && bright=0

	echo "Brightness set to $bright / $maxb"
	sudo tee $path/brightness <<< $bright >/dev/null
}

# Build and run a c, cpp, java (may not work) or sh file.
brun(){
	local usage="Usage: ${FUNCNAME[0]} <sourcefile>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	# We will divide the script arguments in three batches: compiler args, source files and program args
	local makeargs=""
	local files=""
	local args=()

	# First batch stops when arguments are no longer prefixed by -
	while [ $# -gt 0 ] && [ ${1:0:1} = "-" ] && [ "$1" != "-" ] && [ "$1" != "--" ]; do
		makeargs+="$1 "
		shift
	done

	# Second batch includes every filename with an extension. Special option '--' is used to
	# signify the end of this second batch
	local multifiles=false
	while [ $# -gt 0 ] && echo $1 | grep -q '\..*' && [ "${1:0:1}" != "-" ]; do
	    if [ ! -f "$1" ] ; then
		echo "File '$1' not found"
		return 2
	    else
		[ "$files" ] && multifiles=true
		files+="$1 "
		shift
	    fi
	done
	[ "$1" = "--" ] && shift

	# Everything else is considered a program argument
	while [ $# -gt 0 ]; do
	    args[${#args[@]}]="$1"
	    shift
	done

	local ret
	firstfile=${files%% *}
	ext=${firstfile##*.}
	case $ext in
		"c") 
			temp=$(mktemp)
			ex=$(basename $temp)
			rm $temp
			if [ -f makefile ] || [ -f Makefile ]; then
				make && ./$ex "${args[@]}"; ret=$?
			else
				gcc $makeargs $files -o $ex && ./$ex "${args[@]}"; ret=$?
			fi
			[ -f $ex ] && rm $ex;;
		"cpp" | "cc") 
			temp=$(mktemp)
			ex=$(basename $temp)
			rm $temp
			if [ -f makefile ] || [ -f Makefile ]; then
				make && ./$ex "${args[@]}"; ret=$?
			else
				g++ $makeargs $files -o $ex && ./$ex "${args[@]}"; ret=$?
			fi
			[ -f $ex ] && rm $ex;;
		"sh")
			chmod 755 $files && ./$files "${args[@]}"; ret=$?;;
		"py")
			python $files "${args[@]}"; ret=$?;;
		"java") 
			local mainfile=$(grep -ERl --include="*java" "public +static +void +main" | head -1)
			[ -f $mainfile ] || { echo "No main class found"; return 3; }
			local package=$(grep -Po "package +\K.*(?=;)" $mainfile)
			if [ ! $package ] && $multifiles; then
				echo "No suitable package found"
				return 3
			fi
			
			local dirstack=($(echo $package | tr -s . ' '))

			pushd . >/dev/null
			builtin cd "$(dirname "$mainfile")"
			for ((i=${#dirstack[@]}-1; i>=0; i--)); do
				[ "$(basename "$PWD")" = "${dirstack[$i]}" ] ||\
					{ echo "Package name does not match with directory structure"; return 3; }
				builtin cd ..
			done
			javac $makeargs $files || return
			if [ $package ]; then
				java $package.$(basename ${mainfile%%.*}) "${args[@]}"
			else
			    java $(basename ${mainfile%%.*}) "${args[@]}"
			fi
			ret=$?

			for class in $files; do
				[ -f ${class%%.*}.class ] && rm ${class%%.*}.class
			done
			popd >/dev/null;;
		*) 
			echo "What the fuck is $ext in $src";;
	esac

	return $ret
}

# Cd to any of the last 10 directories in your history with 'cd -Number'. Use 'cd --' to see the history
cd_func (){
	local x2 the_new_dir adir index
	local -i cnt

	if [[ $1 ==  "--" ]]; then
		dirs -v
		return 0
	fi

	the_new_dir=$1
	[[ -z $1 ]] && the_new_dir=$HOME

	if [[ ${the_new_dir:0:1} == '-' ]]; then
		#
		# Extract dir N from dirs
		index=${the_new_dir:1}
		[[ -z $index ]] && index=1
		adir=$(dirs +$index)
		[[ -z $adir ]] && return 1
		the_new_dir=$adir
	fi

	# '~' has to be substituted by ${HOME}
	[[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

	#
	# Now change to the new dir and add to the top of the stack
	pushd "${the_new_dir}" > /dev/null || return 1
	ls
	the_new_dir=$PWD

	# Trim down everything beyond 11th entry
	popd -n +11 2>/dev/null 1>/dev/null

	# Remove any other occurence of this dir, skipping the top of the stack
	for ((cnt=1; cnt <= 10; cnt++)); do
		x2=$(dirs +${cnt} 2>/dev/null)
		[[ $? -ne 0 ]] && return 0
		[[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
		if [[ "${x2}" == "${the_new_dir}" ]]; then
			popd -n +$cnt 2>/dev/null 1>/dev/null
			cnt=cnt-1
		fi
	done

	return 0
}

# Give some use to the above function
alias cd=cd_func

# Finds a vm in any of $VBOXHOME or $VMWARE and stores its path in the variable vm
_findvm() {
	if  ( [ -z "$VBOXHOME" ]   || [ ! -d "$VBOXHOME" ]  ) &&\
	    ( [ -z "$VMWAREHOME" ] || [ ! -d "$VMWAREHOME" ]) &&\
		( [ ! -d /ssd  ] ); then
		>&2 echo "Err: Could not find the VMs folder. Check that the enviromental variables
		\$VBOXHOME or \$VMWAREHOME are set and point to valid paths"
		return 3
	fi

	local vmpath vmhome
	if [ "$1" = "vb" ]; then
		vmhome="$VBOXHOME"
		if [ -z "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VBOXHOME is not set"
			return 2
		elif [ ! -d "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VBOXHOME doesn't point to a valid directory"
			return 2
		fi
		shift
	elif [ "$1" = "vw" ]; then
		vmhome="$VMWAREHOME"
		if [ -z "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VMWAREHOME is not set"
			return 2
		elif [ ! -d "$vmhome" ]; then
			>&2 echo "Enviroment variable \$VMWAREHOME doesn't point to a valid directory"
			return 2
		fi
		shift
	else
		local opt
		for opt in "$VBOXHOME" "$VMWAREHOME" "/ssd/VirtualBoxVMs"; do
			[ -n "$opt" ] && [ -d "$opt" ] && vmhome+="$opt "
		done
	fi

	[ $# -lt 1 ] && return 1

	if [ -z "$vmhome" ]; then
		>&2 echo "Err: No VM home folder specified and the default ones could not be found"
		return 2
	fi


	local vmname="$1"

	found=false
	for vmpath in $vmhome; do
		if [ -n "$vmpath" ] && [ -d "$vmpath" ]; then
			if [ ! -d "$vmpath/$vmname" ]; then
				# Try to correct spelling errors. Usually the case-sensitivity will be fixed with this
				local ivmname=$(find $vmpath -maxdepth 1 -type d | grep -Fi $vmname | head -1)
				if [ -n "$ivmname" ] && [ -d "$ivmname" ]; then
					vm="$ivmname"
					return 0
				else
					continue
				fi
			else
				vm="$vmpath/$vmname"
				return 0
			fi
		else
			continue
		fi

	done
	
	>&2 echo "Err: '$1' is not a vm"
	return 1
}

# Cd into a VM located in my VMs folder. Requires VBOXHOME or VMWAREHOME to be set (see .bashrc)
cdvm() {
	local usage="Usage: ${FUNCNAME[0]} [vb|vw] [VMName]
 Examples:
 $ cdvm arch           # Find a vm folder called arch in any of the VM home folders
 $ cdvm vb ubuntu      # Find a virtualbox vm called ubuntu
 $ cdvm vw             # Cd to the home directory of vmware
 "

	local vmpath
	if [ "$1" = "vb" ]; then
		vmpath="vb"
	   	shift 
	elif [ "$1" = "vw" ]; then
		vmpath="vw"
		shift
	fi

	# If the user didn't specify anything, try to at least cd into the home vm directory
	if [ $# -lt 1 ]; then
		# Allow the user to only pass 'vb' or 'vw' as a parameter to cd into the home vm directory of those
		if [ -z $vmpath ]; then
			if [ -n "$VBOXHOME" ] && [ -d "$VBOXHOME" ]; then
				cd "$VBOXHOME"
			else
				if [ -n "$VMWAREHOME" ] && [ -d "$VMWAREHOME" ]; then
					cd "$VMWAREHOME"
				else
					>&2 echo "No parameters passed and enviromental variables aren't set properly"
					return 1
				fi
			fi
		else
			if [ $vmpath = "vb" ] && [ -n "$VBOXHOME" ] && [ -d "$VBOXHOME" ]; then
				cd "$vmpath" 
			elif [ $vmpath = "vw" ] && [ -n "$VMWAREHOME" ] && [ -d "$VMWAREHOME" ]; then
				cd "$vmpath"
			else
				>&2 echo "Err: '$1' is not a valid identifier for a VM home folder"
				return 1
			fi
			return 0
		fi
	else
		# It doesn't matter if vmpath is not set
		_findvm $vmpath $1
		local ret=$?
		[ $ret = 0 ] && cd "$vm"
	fi

	return $ret
}

# Create a conda environment with a few defaults
cenv(){
	local usage="Usage: ${FUNCNAME[0]} <env-name> [python-version]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	local env=$1
	shift

	local python_version defaults
	while [ $# -gt 0 ]; do
		if [ "$1" = "--defaults" ]; then
			defaults=true
		elif [[  "$1" =~ ^[\.0-9]+$ ]]; then
			python_version=$1
		else
			echo "Wrong argument: $1"
			return 1
		fi
		shift
	done

	conda config --set always_yes true
	if ! conda create -n "$env" "python=$python_version"; then
		echo "Error creating conda environment"
		return 2
	fi

	homes=$(conda config --show pkgs_dirs | grep -o '/.*/')
	if [ -z "$homes" ]; then
		echo "W: Couldn't get conda home dirs. Not symlinking terminfo."
	else
		for home in $homes; do
			rm -rf "${home}envs/$env/share/terminfo"
			ln -s /usr/share/terminfo "${home}envs/$env/share"
			break
		done
	fi

	conda deactivate
	conda activate "$env"
	$defaults && pip install neovim ptpython flake8 pylint jedi
	if [ -f setup.py ]; then
		pip install -e.
	elif [ -f requirements.txt ]; then
		pip install -rrequirements.txt
	fi
}


# Obtains the source code of a program in Arch Linux
code(){
	local force=false
	[ "$1" = "-f" ] && { force=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <Program> [destination]"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	cwd="$PWD"
	if ! $force && hash yaourt 2> /dev/null; then
		if yaourt -Ssq "$1" | grep -qE "^$1$"; then
			[ -n "$target" ] && [ -d "$target" ] && cd "$target"
			yaourt -G "$1"
			[ -d "$1" ] || return 2

			cd "$1" 
			[ -f PKGBUILD ] || return 3
			makepkg -od --skippgp
			if [ -d src ] && [ "$(ls -A src)" ]; then
				ls -AQI src | xargs rm -rf
				builtin cd src
				find -L . -name . -o -type d -prune -o -type l -exec rm {} +
				builtin cd ..
				find src -mindepth 1 -print0 | xargs -0 mv -t . 2>/dev/null
				rmdir src
			else
				exts=".tar.gz .tar.xz .tar.bz2"
				for ext in $exts; do
					[ "$(ls ./*$ext 2>/dev/null)" ] || continue
					tar --wildcards -xf ./*$ext
				done
				srcdir="$(ls -d $1*/)"
				if [ -d "$srcdir" ]; then
					len=${#srcdir}
					((len--))
					srcdir=${srcdir:0:$len}
					find . -maxdepth 1 -mindepth 1 ! -name "$srcdir" -print0 | xargs -0 rm -rf
					find "$srcdir" | wc -l > list
					find "$srcdir" -mindepth 1 -print0 | xargs -0 mv -t . 2>/dev/null
					rmdir "$srcdir"
					find . | wc -l >> list
				else
					echo "Err: Could not download sources for $1" 2>&1
					return 3
				fi
			fi
		else
			echo "Program '$1' not found in repos"
			return 2
		fi
	else # I guess we'll have to do it the pacman way. That is, with sudo commands
		if ! hash pacman 2>/dev/null; then
			echo "Err: This script only works on Arch Linux for now"
			return 3
		fi
		local repo=$(pacman -Ss $1  | grep -E ".*/$1 .*[0-9]+[\.[0-9]*|\-[0-9]]+" | cut -d / -f1)
		if [ "$repo" ]; then
			sudo abs
			sudo abs "$1"
			local target="$HOME/Stuff"
			if [ -n "$2" ]; then
				if [ ! -d "$2" ]; then
					echo "W: Directory $2 not found. Will copy to ~/Stuff"
				else
					target=$2
				fi
			fi

			cp -r "/var/abs/$repo/$1" "$target"
			cd "$target/$1"
		fi
	fi
}


# Compare 2 or 3 files and open a diffviewer if they are different
comp(){
	_comp "$@" 2>/dev/null
}

_comp() {
	if [ "$1" = "-m" ]; then 
		local difview=$2
		if hash $difview 2>/dev/null; then 
			shift 2 
		else
			echo "Program '$2' is not installed"
			return 2
		fi
	fi

	local usage="Usage: ${FUNCNAME[0]} <list-of-files>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }
	for name in "$@"; do
		if [ -d "$name" ]; then
			echo "$name is a directory"
			return 2
		elif [ ! -f "$name" ]; then
			echo "File '$name' does not exist"
			return 2
		fi
	done

	if [ -z "$difview" ]; then
		for dif in vimdiff meld colordiff diff cmp; do
			if hash $dif 2>/dev/null; then
				difview=$dif
				break
			fi
		done
	fi

	[ -z $difview ] && { echo "Err: Couldn't find a diff viewing program. Please specify it with -m"; return 3; }

	local changed=false
	while [ $# -ge 2 ]; do
		if [ $(($# % 2)) = 0 ]; then
			 [ -z "$(diff -qb "$1" "$2")" ]  || { changed=true; "$difview" "$1" "$2"; }
			shift 2
		elif [ $# = 3 ]; then 
			# Results in this order: all equal, 3 is different, 1 is different, 2 is different, all are different
			cmp -s "$1" "$2"\
				&&  (cmp -s "$1" "$3" && continue || { "$difview" "$1" "$3"; cp "$1" "$2"; })\
				||  (cmp -s "$2" "$3" && { "$difview" "$1" "$2"; cp "$2" "$3"; } ||\
				(cmp -s "$1" "$3" && { "$difview" "$1" "$2"; cp "$1" "$3"; } || "$difview" "$1" "$2" "$3"))
			changed=true
			shift 3
		fi
	done

	$changed || echo "Nothing to see here"
	[ $# = 1 ] && echo "W: Couldn't handle last argument '$1'"
	return 0
}


# Copy and cd
cpc() {
	if [ $# -ge 2 ]; then
		for dst; do true; done
		if ! [ -d "$dst" ]; then
			echo "Err: Destination directory not found"
			return 2
		fi

		# We'll concat the string so it's only one command (is it more efficient?)
		local cmmd="cp -vr "
		while [ $# -gt 1 ]; do
			cmmd+="$1 "
			shift
		done
		cmmd+="$dst"
		$cmmd #Actually execute the command
		cd "$dst"
	else
		echo "Err: Missing arguments"
		return 1
	fi

	return 0
}


# TODO Learn to configure shared folders with virtualbox's cli
# BUG Not working properly when vmname is the first argument
# Copies files to the specified VM located in my VMs folder. Saves me a few keystrokes from time to time 
cpvm() {
	# Quite a hacky way to do things, but it does the job
	local switches="rv" # The only default switch
	while [[ $1 =~ -.* ]]; do
		local newswitch=${1##*-}
		echo "$switches" | grep -q "$newswitch" || switches+=$newswitch;  # Eliminate duplicates
		shift
	done

	# And now that we have our cp switches, parse the arguments as normal
	local usage="Usage: ${FUNCNAME[0]} [vb|vmw] [copyopts] <files> <VMName>
	OR ${FUNCNAME[0]} [vb|vmw] [copyopts] <VMName> <files>.

	Where copytopts is a list of flags to pass to the command cp, and vb|vmw is an optional argument
	to specify whether you want to look for the vm in the Virtualbox or VMWare home folders, whose
	paths should be set as the VBOXHOME and VMWAREHOME environmental variables."

	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	if  ( [ -z "$VBOXHOME" ]   || [ ! -d "$VBOXHOME" ]  ) &&\
		( [ -z "$VMWAREHOME" ] || [ ! -d "$VMWAREHOME" ]); then
		echo 'Err: Could not find the VMs folder. Check that the enviromental variables\
			$VBOXHOME or $VMWAREHOME are set and point to valid paths'
		return 3
	fi

	local vmpath vm vmhome
	if [ "$1" = "vb" ]; then
		vmhome="vb"
		shift
	elif [ "$1" = "vw" ]; then
		vmhome="vw"
		shift
	fi

	# Obtain the last argument passed
	for last; do true; done

	# Try to flip the arguments. See if the first or the last argument are valid vms
	local target ret
	local flipped=false
	_findvm $vmhome "$2" 
	ret=$?
	if [ $ret = 0 ]; then
		local target="$vm/Shared"
	elif [ $ret -lt 3 ]; then
		_findvm $vmhome "$last"
		local ret=$?
		if [ $ret = 0 ]; then
			flipped=true
			target="$vm/Shared"
		else
			return $ret	
		fi
	elif [ $ret -ge 3 ]; then
		return $ret #An error message should have been printed already
	fi

	# If we found the vm folder, but there's not a subfolder called 'Shared'
	if [ ! -d "$target" ]; then
		echo "W: Had to create the folder called Shared. The folder sharing mechanism may not be set up"
		mkdir "$target"
	fi

	#We should have at least the -r switch right now.
	cmmd="cp -$switches " #Notice the blank space at the end
	if ! $flipped; then 
		while [ $# -gt 1 ]; do
			if [ ! -e "$1" ]; then
				>&2 echo "Err: Source file '$src' does not exist"
				return 2
			fi
			cmmd+="$1 "
			shift
		done
	else
		while [ $# -ge 2 ]; do
			if [ ! -e "$2" ]; then
				>&2 echo "Err: Source file '$src' does not exist"
				return 2
			fi
			cmmd+="$2 "
			shift
		done
	fi

	( $cmmd "$target" )

	return 0
}

# Loads my configuration of gdrivefs and mounts my GDrive in a system folder
drive() {
	local mp pid i
	mp="$(pgrep -a gdfs | head -1)"
	if [ "$mp" ]; then
		pid=${mp%% *}
		mp=${mp##* } # Get the last word of the process, which should be the mountpoint
		sudo fusermount -uz "$mp"
		sudo pkill gdfs
		for i in $(seq 0 9); do
			if ps --pid "$pid"; then
				sleep 1
			else
				break
			fi
		done
		ps --pid "$pid" && sudo kill -9 "$pid"
	else
		mp="$HOME/Drive"
	fi

	[ "$1" = "-k" ] && return 0

	[ ! -d "$mp" ] && mkdir -p "$mp"
	sudo gdfs -o big_writes -o allow_other "$HOME"/.config/gdfs/gdfs.auth "$mp"

	# Force it to cache the entire list of files
	if [ -d "$mp" ] && ([ -z "$1" ] || [ "$1" != "-n" ]); then
		find "$mp" > /dev/null &
	fi
	return 0
}


# Dump the contents of a folder into the its parent directory and delete it afterwards.
dump() {
	aggressive=false
	[ "$1" = "-a" ] && { aggressive=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <dir>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	local target="$1"

	if [ "$(readlink -f "$target")" = "$PWD" ]; then
		target="$PWD"
		cd ..
	fi
	if [ ! -d "$target" ]; then
		echo "Err: The specified path does not exist"
		return 2
	fi

	local findcmd
	if $aggressive; then 
		findcmd="find $target -mindepth 1 -type f "
	else
		findcmd="find $target -mindepth 1 -maxdepth 1 "
	fi

	local file dest
	dest="$PWD"
	# We'll use -d to get the last results first. This way we can move the deepest files first in aggressive
	# mode. Otherwise we would move their parent directories before them, and would result in an error
	for file in $( $findcmd ); do
		if $aggressive; then
			if [ -f "$file" ]; then 
				mv "$file" "$dest"
			else
				echo "W: $file does not exist"
			fi
		else
			if [ -e "$file" ]; then 
				mv "$file" "$dest"
			else
				echo "W: $file does not exist"
			fi
		fi
	done

	rm -rf "$target"

	return 0
}

# Count the number of files with a given set of extensions
function files {
	local usage="Usage: ${FUNCNAME[0]} [opts] [extensions]

Supported options:
-d <dir>:    Specify a path to search for files
-m <depth>:  Specify the maximum depth of the search
-a:          Consider all extensions, not just code files
-c:			 Don't group by extension, just count the total number of files
-h:		 Show this help message and exit
"

	local path='.'
	local anyfile=false
	local count=false
	local files depth extensions opt OPTIND
	while getopts ":d:m:ach" opt; do
		case $opt in
			d)
				if [ -d "$OPTARG" ]; then
					files=$OPTARG
					if [ "${OPTARG:$((${#OPTARG}-1)):1}" != "/" ]; then ##Get the last char of the string
						files=$files/
					fi
					path=$files
				else
					echo "Err: Directory $OPTARG does not exist"
					return 2
				fi;;
			m)
				depth=$OPTARG
				local isnum='^[0-9]+$'
				if ! [[ "$depth" =~ $isnum ]]; then
					echo "Depth argument must be a number"	
					echo "$usage"
					return 1
				fi

				if [ "$depth" -lt 1 ]; then 
					echo "You won't get any results with such a stupid depth"
					return 2
				fi;;
			a)
				anyfile=true;;
			c)
				count=true;;
			h)
				echo "$usage"
				return 0;;
			\?)
				>&2 echo "Err: Invalid option -$OPTARG"
				echo "$usage"
				return 1;;
			:)
				>&2 echo "Err: Option -$OPTARG requires an argument"
				return 1;;
		esac
	done

	shift $((OPTIND -1))

	if ! $anyfile; then
		if [ $# -gt 0 ]; then
			extensions=( "$@" )
		else
			extensions=( c cpp h hpp S asm java js hs py pl sh cs css cc html htm php sql rb el vim bats )
		fi
	fi

	local total report
	local totalcount=0

	local findcmd="find $path "
	[ -n "$depth" ] && findcmd+="-maxdepth $depth "
	findcmd+="-type f "
	if $count; then
		$findcmd | wc -l
		return 0
	elif $anyfile; then
		local tempfile=$(mktemp)
		echo "$($findcmd | wc -l) total"
		$findcmd -exec basename {} \; > "$tempfile"
		while read -r filename; do
			echo "${filename##*.}"
		done < "$tempfile" | sort | uniq -c | sort -nr 
		rm "$tempfile"
		return 0
	else
		for ext in "${extensions[@]}"; do
			total="$($findcmd -name "*.$ext" | wc -l)"	
			if [ "$total" -gt 0 ]; then
				report+="$total $ext\n"
				(( totalcount+=$total ))
			fi
		done

		report="$(echo -e "$report" | sort -hsr | more)"
		printf '%s total\n%s\n' "$totalcount" "$report"
	fi

	return 0
}

# Unmount a device and mount it in a local folder called "folder"
folder() {
	_cleanup() {
		builtin cd "$(dirname "$mp")"
		if grep -qs "$1" /proc/mounts; then
			if ! sudo umount "$1"; then
				echo "W: Couldn't unmount $1"
			fi
		fi
		if [ -d "$1" ]; then
			if [ -z "$(ls "$1")" ]; then
				if ! rmdir "$1" 2>&1 ; then
					sudo rmdir "$1" 2>/dev/null
				fi
			fi
		fi
	}

	local usage="Usage: ${FUNCNAME[0]} [-o <folder>] <-k|device>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	if [ "$1" = "-o" ]; then
		[ -z "$2" ] && { printf 'No folder name provided\n%s' "$usage"; return 1; }	
		local folder="$2"
		shift 2
	else
		local folder="folder"
	fi

	# If we consumed all the arguments already, it means no device name has been passed
	[ $# -lt 1 ] && { echo "$usage"; return 1; }

	if [ "$1" = "-k" ] || [ "$1" = "kill" ]; then

		# If the mountpoint was passed to -k as a parameter use it. Otherwise we'll have to guess what the mountpoint is
		if [ -n "$2" ]; then
			[ ! -d "$2" ] && { echo "The argument given is not a folder"; return 2; }
			if ! grep -qs "$2" /proc/mounts; then
				echo "The argument given to -k is not a mountpoint"
				return 2
			else
				_cleanup "$2"
				return 0
			fi
		else
			if [ ! -d "$folder" ] || [ -z "$(df "$folder")" ]; then
				# Get the first parent for this folder that is a mountpoint
				local mp="$(df --output=target . | tail -1)"

				# Try to guess if we're inside the mounted folder
				if echo "$mp" | grep -Eq ".*/$folder(/.*|$)"; then
					cd "$(dirname "$mp")" #Jump up to our mountpoint
					folder="$mp" #Change the folder we will umount down below
				else
					echo "Err: No parent mountpoint or it's not one of our own."

					# Desperately try to find a parent mountpoint
					mp="$(df --output=target | grep -E ".*/$folder(/.*|$)" | tail -1)"
					if [ -n "$mp" ]; then
						local opt="default"

						if [ "$2" != '-f' ]; then
							local src="$(df --output=source "$mp" | tail -1)"
							local fstype="$(df --output=fstype "$mp" | tail -1)"

							while [ -n "$opt" ] && [ $opt != 'n' ] && [ $opt != 'y' ]; do
								echo -n "Do you want to risk it and unmount $src [$fstype] from $mp? (y/N): "
								read -rn2 opt
								printf '\n'
							done
						else
							opt='y'
						fi
						if [ $opt = 'y' ]; then
							_cleanup "$mp"	
						else
							echo "Aborted."
						fi
						return 0
					else
						return 3
					fi
				fi
			fi

			_cleanup "$folder"
		fi
		return 0
	fi


	# Regular expression that will allow things like 'folder d1' to match /dev/sd1
	local dXY="^[a-z][0-9]*$"
	local device

	if [[ $1 =~ $dXY ]]; then
		device="/dev/sd$1"
	elif [ -b "/dev/$1" ]; then
		device="/dev/$1"
	elif [ -b "$1" ]; then
		device="$1"
	fi

	if ! [ -e "$device" ]; then
		echo "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs "$device" /proc/mounts; then
			if ! sudo umount "$device"; then
				echo "Err: There was an error unmounting $device. Close any application that may be using it and try again"
				return 3;
			fi
		fi

		if ! [ -d "$folder" ]; then
			if ! mkdir "$folder" && ! sudo mkdir "$folder"; then
				echo "Err: could not create dir"
				return 3
			fi
		fi

		# Get the id's as the normal users, instead of using the sudo ones
		opts="uid=$(id -u),gid=$(id -g)"
		if ! sudo mount -o "$opts" "$device" "$folder" 2>/dev/null; then
			if ! sudo mount -o "rw" "$device" "$folder" 2>/dev/null; then
				if ! sudo mount "$device" "$folder" 2>/dev/null; then
					echo "Err: Could not mount $device"
					rmdir "$folder"
					return 3
				else
					echo "W: Could not mount device r-w, mounted read only"
				fi
			fi
		fi

		# Just in case, politely ask for write permissions
		if ! chmod a+w "$folder" 2>/dev/null; then
			sudo chmod a+w "$folder"
		fi
	fi
	# cd "$folder"

	return 0
}


# Count the lines of code for a specific set of extensions
lines(){
	local usage="Usage: ${FUNCNAME[0]} [opts] [extensions]

Supported options:
-d <dir>:    Specify a path to search for files
-m <depth>:  Specify the maximum depth of the search
-a:          Ignore extensions. Search every file 
-h:          Show this help message
"

	local path='.'
	local anyfile=false
	local files depth extensions OPTIND
	while getopts ":d:m:ah" opt; do
		case $opt in
			d)
				if [ -d "$OPTARG" ]; then
					files=$OPTARG
					if [ "${OPTARG:$((${#OPTARG}-1)):1}" != "/" ]; then ##Get the last char of the string
						files=$files/
					fi
					path=$files
				else
					echo "Err: Directory $OPTARG does not exist"
					return 2
				fi;;
			m)
				depth=$OPTARG
				local isnum='^[0-9]+$'
				if ! [[ "$depth" =~ $isnum ]]; then
					echo "Depth argument must be a number"	
					echo "$usage"
					return 1
				fi

				if [ "$depth" -lt 1 ]; then 
					echo "You won't get any results with such a stupid depth"
					return 2
				fi;;
			a)
				anyfile=true;;
			h)
				echo "$usage"
				return 0;;
			\?)
				>&2 echo "Err: Invalid option -$OPTARG"
				echo "$usage"
				return 1;;
			:)
				>&2 echo "Err: Option -$OPTARG requires an argument"
				return 1;;
		esac
	done

	shift $((OPTIND -1))
	if ! $anyfile; then
		if [ $# -gt 0 ]; then
			extensions=( "$@" )
		else
			extensions=( c cpp h hpp S asm java fxml js hs py pl sh cs css cc html htm php sql rb el vim xaml )
		fi
	fi

	local tempfile findcmd
	tempfile=$(mktemp)
	findcmd="find $path "
	[ -n "$depth" ] && findcmd+="-maxdepth $depth "
	findcmd+="-type f "

	if $anyfile; then
		$findcmd -fprint0 "$tempfile"
	else
		local lastpos=$(( ${#extensions[*]} -1 ))	
		local lastelem=${extensions[$lastpos]}

		local names='.*\.('
		for ext in "${extensions[@]}"; do
			names+="$ext"
			[ "$ext" != "$lastelem" ] && names+="|"
		done

		names+=")"

		# Findcmd: find $path -maxdepth n -type f
		findcmd+="-regextype posix-extended -regex $names -fprint0 $tempfile"

		( $findcmd )
	fi

	sed -i 's|\./||g' "$tempfile" 
	wc -l "--files0-from=$tempfile" | sort -hsr | more

	rm "$tempfile"
	return 0
}

# Convert any number of files to mp3
function mp3() {
	function _mp3_exit() {
		[ -f "$tmp" ] && rm "$tmp"
		# Delete all current in-process files
		output=()
		for output in "${outputs[@]}"; do 
			[ -f "$output" ] && rm "$output"
		done
		kill "$(pgrep -P $$)" >/dev/null 2>&1
	}

	local remove=false
	[ $# -ge 1 ] && [ "$1" = "-r" ] && { remove=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <mp3 files>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	trap '_mp3_exit; return 127' SIGINT SIGTERM
	local pids inputs outputs cnt tmp
	tmp=$(mktemp)


	# To improve performance, this script will launch different instances of ffmpeg at the same
	# time. To avoid overloading the system with too many processes, it will only launch them in
	# batches of nprocessors at a time, and then wait for all of them to finish before starting
	# with the next batch.
	while [ $# -gt 0 ]; do 
		pids=()
		inputs=()
		outputs=()
		cnt=0

		while IFS= [ $cnt -lt "$(nproc)" ] && [ $# -gt 0 ]; do
			local output="${1%%.*}".mp3
			ffmpeg -y -codec:a libmp3lame -max_muxing_queue_size 9999 -qscale:a 0 -b:a 256k "$output" -i "$1" </dev/null 2>/dev/null &

			pids[$cnt]=$!
			inputs[$cnt]="$1"
			outputs[$cnt]="$output"

			((cnt++))
			shift
		done

		for i in $(seq 0 $((cnt-1))); do
			if wait ${pids[$i]}; then
				echo "${inputs[$i]} => ${outputs[$i]}"
				$remove && rm "${inputs[$i]}"
			else
				rm "${inputs[$i]}"
			fi
		done
	done

	[ -f "$tmp" ] && rm "$tmp"
	return 0
}

# Move and cd
mvc() {
	if [ $# -ge 2 ]; then
		for dst; do true; done
		if ! [ -d "$dst" ]; then
			echo "Err: Destination directory not found"
			return 2
		fi

		# We'll concat the string so it's only one command (is it more efficient?)
		local cmmd="mv -v "
		while [ $# -gt 1 ]; do
			cmmd+="$1 "
			shift
		done
		cmmd+="$dst"
		( $cmmd ) #Actually execute the command
		cd "$dst"
	else
		echo "Err: Missing arguments"
		return 1
	fi

	return 0
}

# Start a vpn service at the specified location. Uses openvpn directly instead of systemctl
oldvpn() {
	_oldvpnkill () {
		pgrep openvpn || return 0
		sudo pkill openvpn 2>/dev/null
		for i in $(seq 0 9); do
			if pgrep openvpn >/dev/null; then
				sleep 1
			else
				break
			fi
		done
		pgrep openvpn && sudo pkill -9 openvpn
	}

	local path="/etc/openvpn"
	local default="UK_London"
	local config="$path/${1:-$default}"
	trap "_oldvpnkill; return" SIGHUP SIGINT SIGTERM
	if [ $# -gt 0 ]; then
		if [ "${1:0:1}" == "-" ]; then
			case "$1" in
				"-l")
					for name in "$path"/openvpn/*.{conf,ovpn}; do
						basename "${name%.*}"
					done | sort | column
					return 0;;
				"-k")
					_oldvpnkill
					return 0;;
				"-s")
					local proc="$(pgrep -a openvpn | head -1)"
					if [ "$proc" ]; then
						local loc=$(echo "$proc" | grep -Eo '/[A-Z].*\.')
						loc=${loc:1:-1}
						echo -n "VPN is running and connected"
						[ "$loc" ] && echo " from $loc." || echo "."
					else
						echo "VPN is not running"
					fi;;
			esac
			return 0
		elif [ -f "$config.conf" ]; then
			config+=".conf"
		elif [ -f "$config.ovpn" ]; then
			config+=".ovpn"
		else
			config+=".conf"
			echo "No config file found for '$1'. Will use default option ${config##*/}"
		fi
	fi
	region="$(basename "$config")"
	region="${region%.*}"
	echo "Starting VPN to $region"
	sudo echo -n || { _oldvpnkill; return 3; } # Get our sudo authentication
	_oldvpnkill 2>/dev/null
	sudo openvpn --config "$config" >/dev/null &
	[ $? = 0 ] || { _oldvpnkill; return 3; }

	sleep 3
	hash publicip 2>/dev/null && publicip
	unset -f _oldvpnkill

	return 0
}

# Recurisvely fix file and directory permissions for an apache dir
permapache() {
	local usage="Usage: ${FUNCNAME[0]} <path>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }

	if ! [ -e "$1" ]; then
		echo "Err: Path does not exist"
		return 1
	else
		if ! [ -d "$1" ]; then
			echo "Err: Path is not a directory"
		fi
	fi

	if [ -d /etc/apache ] || [ -d /etc/apache2 ]; then
		user=www-data
		group=www-data
	else
		user=http
		group=http
	fi

	sudo chown -R $user:$group "$1"
	sudo find "$1" -type f -exec chmod 0664 {} \;
	sudo find "$1" -type d -exec chmod 0775 {} \;
}


# Opens all the pdf files in the specified directory
pdfs() {
	local viewer="firefox"
	while [ $# -gt 0 ]; do 
		if [ "$1" = "-v" ]; then
			if [ -z "$2" ]; then
				echo  "Err: An argument is required for -v" 2>&1
				return 1
			else
				if ! hash "$2" 2>/dev/null; then
					echo "Err: Program '$2' is not installed"
					return 2
				else
					viewer="$2"
					shift 2
				fi
			fi
		else
			if ! [ -d "$1" ]; then
				echo "Err: Destination directory '$1' not found"
				return 2
			else
				pushd . >/dev/null
				cd "$1"
				shift
			fi
		fi
	done

	$viewer ./*.pdf >/dev/null 2>&1 &
	if [ $# -gt 0 ]; then
		popd >/dev/null
	fi

	return 0
}


# Mounts a disk, copies a set of files from it and then unmounts it.
# This is just a wrapper for the 'folder' function, so make sure that one is in you system too
pop() {
	trap 'folder -k' SIGHUP SIGINT SIGTERM 
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	if [ $# -lt 2 ]; then
		echo "$usage"
		return 1
	fi

	for last; do true; done

	if ! folder "$last"; then
		return 3
	fi
	dest="folder"

	# Copy stuff from the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$dest/$1" ]; then
			echo "W: File '$1' does not exist"
		else
			if ! cp -r "$dest/$1" .; then
				echo "W: File '$1' could not be copied"
			else
				echo "Copied '$1'"
			fi
		fi
		shift
	done

	# Done copying, unmount the device
	folder -k
	return $?
}
alias pull=pop


# Mounts a disk, copies a set of files into it and then unmounts it.
# This is just a wrapper for the 'folder' function, so make sure that one is in you system too
push() {
	trap 'folder -k' SIGHUP SIGINT SIGTERM 
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	if [ $# -lt 2 ]; then
		echo "$usage"
		return 1
	fi

	for last; do true; done

	if ! folder "$last"; then
		return 3
	fi

	#I had no good way to figure out the name of the mounted
	#folder, so let's assume it's the default
	dest="folder"

	# Copy stuff to the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$1" ]; then
			echo "W: File '$1' does not exist"
		else
			if ! cp -r "$1" "$dest"; then
				echo "W: File '$1' could not be copied"
			else
				echo "Copied '$1'"
			fi
		fi
		shift
	done

	# Done copying, unmount the device
	folder -k
	return $?
}

# Had to declare it as function. 'publicip() {' doesn't work for some reason
# Pretty self-explainatory
function publicip {
	echo "Getting ip..."
	local ip="$(wget -T7 https://ipinfo.io/ip -qO -)"
	[ -z "$ip" ] && { echo "Timeout"; return 3; }

	echo "Getting location..."
	local loc="$(wget -T5 http://ipinfo.io/city -qO -)"
	[ -z "$loc" ] && loc="$(wget -T5 http://ipinfo.io/country -qO -)"

	echo -n "$ip"
	if [ -n "$loc" ]; then
		echo " -- $loc" 
	else
		echo ""
	fi
}

function reload() {
	if [ $# -gt 0 ] && [ "$1" = "-f" ]; then
		for al in $(alias | awk -F'[ =]' '{print $2}'); do
			unalias $al
		done
		for f in $(declare -F | awk '{print $3}'); do
			[ ${f:0:1} != "_" ] && unset $f
		done

		[ -f "$HOME/.Xresources" ] && xrdb $HOME/.Xresources
		unset PROMPT_COMMAND
		unset POWERLINE_RUNNING
		unset BASH_COMPLETION_LOADED
	fi

   	source "$HOME/.bashrc"
}

# TODO Detect interfaces
# TODO Add passphrase prompt
# wpa_supplicant wrapper. Used to connect to the given ssid
supplicant() {
	local list=false
	local confdir=/etc/wpa_supplicant
	local interface=wlp3s0
	[ ! -d $confdir ] && { echo "Err: $confdir does not exist"; return 2; }

	while [ $# -gt 0 ] && [ ${1:0:1} = "-" ]; do
		if [ "$1" = "-l" ]; then
			list=true
		elif [ "$1" = "-k" ]; then
			sudo pkill wpa_supplicant

			# Give it 10 seconds to close itself or kill it by force
			local i
			for i in $(seq 10); do
				if ps aux | grep -v grep | grep -q wpa_supplicant; then
					sleep 1
				else
					return 0
				fi
			done
			sudo pkill -9 wpa_supplicant
			return 0
		elif [ "$1" = "-i" ]; then
			interface="$2"
			shift
		elif [ "$1" = "-s" ]; then
			if hash iwlist 2>/dev/null; then
				sudo ip link set dev "$interface" up
				sudo iwlist "$interface" scanning | grep -i ssid | tr -d '"' | cut -d: -f2- | sort | uniq
				return 0
			else
				echo "Err: Please install iwlist to scan available networks"
				return 2
			fi
		else
			echo "Err: Unrecognized option: $1"
		fi
		shift
	done

	if ! ip addr show "$interface" >/dev/null 2>&1; then
		echo "Err: Interface '$interface' not found"
		return 2	
	fi

	local ssids="$(grep ssid "$confdir/$interface.conf" | tr -d '"' | cut -d= -f2-)"
	if $list; then
		echo "$ssids"
		return 0
	fi

	local ssid="$1"
	[ -z "$ssid" ] && { echo "Err: No SSID given"; return 1; }
	local found=false
	for s in $ssids; do
		[ "$s" = "$ssid" ] && { found=true; break; }
	done
	if ! $found; then
		# Try very hard to find a similar ssid
		local choices="$(echo "$ssids" | grep -wi "$ssid")"
		if [ -z "$choices" ]; then
			choices="$(echo "$ssids" | grep -i "$ssid")"
			if [ -z "$choices" ]; then
				echo "Err: SSID $ssid not found"
				return 2
			else
				if [ "$(echo "$choices" | wc -w)" -gt 1 ]; then
					echo "Did you mean $(echo -e "$ssids"| tr -s '\n', ', ')?"
					return 4
				else
					echo "$ssid auto corrected to $choices"
					ssid="$choices"
				fi
			fi
		else
			if [ "$(echo "$choices" | wc -w)" -gt 1 ]; then
				echo "Did you mean $(echo -e "$ssids"| tr -s '\n', ', ')?"
				return 4
			else
				echo "$ssid auto corrected to $choices"
				ssid="$choices"
			fi
		fi
	fi

	sudo ip link set dev "$interface" up	
	if hash iwlist 2>/dev/null; then
		local avail="$(sudo iwlist "$interface" scanning | grep -i ssid | tr -d '"' | cut -d: -f2- | sort | uniq)"
		if ! echo "$avail" | grep -qw "$ssid"; then
			echo "Err: $ssid is not available right now"
			return 3
		fi
	else
		echo "Please install iwlist if you want to check if the network is available"
	fi

	sudo ip link set dev "$interface" down || return 3
	sudo ip link set dev "$interface" up || return 3
	sudo wpa_supplicant -B "-i$interface" -c "$confdir/$interface.conf" 
}

# Swap two files. Rename $1 to $2 and $2 to $1
swap() {
	local usage="Usage: ${FUNCNAME[0]} <file1> <file2>"
	[[ $# -lt 2 ]] && { echo "$usage"; return 1; }

	[ ! -e "$1" ] &&  { echo "File $1 does not exist"; return 2; }
	[ ! -e "$2" ] &&  { echo "File $2 does not exist"; return 2; }

	local tmp=$(mktemp -d)
	mv "$1" "$tmp" >/dev/null
	mv "$2" "$1" >/dev/null
	mv "$tmp/$1" "$2" >/dev/null
	rm -rf "$tmp" >/dev/null
}

# Activate a vpn at the specified location. Requires openvpn to be properly configured and a username and password to be set
vpn(){
	function _vpnkill {
		local reg
		for reg in $(systemctl | grep -Eo "openvpn-client@.*" | cut -d ' ' -f1); do
			sudo systemctl stop "$reg"
			printf "\rStopped vpn at $reg\n"
		done
	}

	local path="/etc/openvpn"
	local default="UK_Southampton"
	local config="$path/${1:-$default}"
	trap "_vpnkill 2>/dev/null; return" SIGHUP SIGINT SIGTERM

	if [ $# -gt 0 ]; then
		if [ "${1:0:1}" = "-" ]; then
			case "$1" in
				"-l")
					for name in "$path"/*.{conf,ovpn}; do
						basename "${name%.*}"
					done | sort | column
					return 0;;
				"-k")
					_vpnkill
					return 0;;
				"-s")
					systemctl status "openvpn-client@$default"
					return 0;;
			esac
			return 0
		elif [ -f "$config.conf" ]; then
			config+=".conf"
		elif [ -f "$config.ovpn" ]; then
			config+=".ovpn"
		else
			echo "No config file found for $1. Will use default option $default"
			config+=".conf"
		fi
	fi
	region="$(basename "$config")"
	region="${region%.*}"
	echo "Starting VPN to $region"
	sudo echo -n || { _vpnkill; return 3; } # Get our sudo authentication
	_vpnkill 2>/dev/null
	sudo systemctl start "openvpn-client@$region" || { _vpnkill; return 3; }
	sleep 3
	hash publicip  2>/dev/null && publicip
	unset -f _vpnkill
	return 0
}

# netcfg/netctl wrapper. Used to connect to a given profile
wifi() {
	local confdir=/etc/netctl
	local interface=wlp3s0
	[ ! -d $confdir ] && echo "Err: $confdir does not exist"

	while [ $# -gt 0 ] && [ ${1:0:1} = "-" ]; do
		if [ "$1" = "-h" ]; then
			echo "Connect to the specified netctl profile. This script must be run as root."
			echo ""
			echo "Usage: ${FUNCNAME[0]} [options] PROFILE"
			echo "Available options:"
			echo "-l: List available profiles in $confdir"
			echo "-k: Stop active netctl profiles"
			echo "-i: Specify the wireless interface (default $interface)"
		elif [ "$1" = "-l" ]; then
			netctl list
			return 0
		elif [ "$1" = "-k" ]; then
			echo "Stopping all netctl profiles..."
			sudo netctl stop-all
			return 0	
		elif [ "$1" = "-i" ]; then
			if [ "$2" ]; then 
				interface="$2"
				shift
			else
				echo "Err: You must provide an argument to -i" >&2
				return 1
			fi
		elif [ "$1" = "-s" ]; then
			if hash iwlist 2>/dev/null; then
				sudo ip link set dev "$interface" up
				sudo iwlist "$interface" scanning | grep -i ssid | tr -d '"' | cut -d: -f2- | sort | uniq
				return 0
			else
				echo "Err: Please install iwlist to scan available networks"
				return 2
			fi
		else
			echo "Err: Unrecognized option: $1"
		fi
		shift
	done

	if ! ip addr show "$interface" >/dev/null 2>&1; then
		echo "Err: Interface '$interface' not found"
		return 2	
	fi

	local conffile="$1"
	if [ ! -f "$confdir/$conffile" ];  then
		# Try very hard to find a similar filename
		conffile="$1.conf"
		[ ! -f "$confdir/$conffile" ] && conffile="$(find $confdir -iname "$1" | head -1)"
		[ ! -f "$confdir/$conffile" ] && conffile="$(find $confdir -iname "*$1*" | head -1)"

		if [ ! -f "$confdir/$conffile" ]; then
			echo "Err: Configuration for $1 not found"
			return 2
		fi
	fi

	local ssid avail ret
	ssid="${conffile%%.*}"
	if hash iwlist 2>/dev/null; then
		sudo ip link set dev "$interface" up
		sleep 2
		avail="$(sudo iwlist "$interface" scanning | grep -i ssid | tr -d '"' | cut -d: -f2- | sort | uniq)"
		ret=$?
		if [ $ret != 0 ]; then
			echo "Err: There was some error scanning for available networks"
			return $ret
		fi
		if ! echo "$avail" | grep -qw "$ssid"; then
			echo "Err: $ssid is not available right now"
			return 3
		fi
	else
		echo "Please install iwlist if you want to check if the network is available"
	fi

	sudo netctl stop-all
	sudo ip link set dev "$interface" down || return 3
	sudo netctl start "$conffile"
}

# Show a sorted list of the most used words in a document
wordCount() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { echo "$usage"; return 1; }
	file=$(echo "$1" | tr -d '\\')
	[ ! -f "$file" ]  && { echo "File '$file' not found"; return 2; }

	tr -cs 'A-Za-zñáéíóúÑÁÉÍÓÚ' '\n' < "$file" | tr A-Z a-z | sort | uniq -c | sort -rn | more

	return 0
}
