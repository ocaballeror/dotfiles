#!/bin/bash

# A collection of little scripts that I find useful in my everyday unix life
# Functions prepended with '_' are not meant to be used directly, and instead serve as auxiliary functions to others. They may have no parameters and little documentation because of this.

# Global return codes
#	0 - Everything went as planned
#	1 - There was an error in the arguments (unsufficient, mistyped...)
#	2 - Referenced files or directories do not exist
#	3 - Other

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
	local value=$1
	if [ "$value" = "-h" ]; then
		errcho "$usage"
		return 0
	fi

	local path="/sys/class/backlight/intel_backlight"
	[ ! -d $path ] && { errcho "Err: Couldn't access path '$path'"; return 2; }
	for filename in max_brightness actual_brightness; do
		if [ ! -f $path/$filename ]; then
			errcho "Err: Couldn't find file $filename"
			return 2
		fi
	done

	local bright maxb current
	maxb=$(cat $path/max_brightness)
	current=$(cat $path/actual_brightness)
	if [ -z "$value" ]; then
		echo "Brightness: $current / $maxb"
		return 0
	fi

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
			errcho "Err: '$value' is not a number"
			return 1
		fi
	fi

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
				errcho "W: Brightness will be set to max brightness $maxb"
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
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }

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
			errcho "Err: File '$1' not found"
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
				make
			else
				gcc $makeargs $files -o $ex
			fi
			./$ex "${args[@]}"
			ret=$?
			[ -f $ex ] && rm $ex;;
		"cpp" | "cc")
			temp=$(mktemp)
			ex=$(basename $temp)
			rm $temp
			if [ -f makefile ] || [ -f Makefile ]; then
				make
			else
				g++ $makeargs $files -o $ex
			fi
			./$ex "${args[@]}"
			ret=$?
			[ -f $ex ] && rm $ex;;
		"sh")
			chmod 755 $files && ./$files "${args[@]}"; ret=$?;;
		"py")
			python $files "${args[@]}"; ret=$?;;
		"java")
			local mainfile=$(grep -ERl --include="*java" "public +static +void +main" | head -1)
			[ -f $mainfile ] || { errcho "Err: No main class found"; return 3; }
			local package=$(grep -Po "package +\K.*(?=;)" $mainfile)
			if [ ! $package ] && $multifiles; then
				errcho "Err: No suitable package found"
				return 3
			fi

			local dirstack=($(echo $package | tr -s . ' '))

			pushd . >/dev/null
			builtin cd "$(dirname "$mainfile")"
			for ((i=${#dirstack[@]}-1; i>=0; i--)); do
				[ "$(basename "$PWD")" = "${dirstack[$i]}" ] ||\
					{ errcho "Err: Package name does not match with directory structure"; return 3; }
				builtin cd ..
			done
			javac $makeargs $files || return 3
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
			errcho "Err: What the fuck is $ext in $src";;
	esac

	return $ret
}

ccs() {
    branch=$(git br | grep '*' | cut -b3-)
    if ! git remote -v | grep -q git@github; then
        errcho "Remote not supported"
        return 1
    fi

    path=$(git remote -v | head -1 | cut -d: -f2 | cut -d. -f1)
    pipeline=$(curl -sL "https://circleci.com/api/v2/project/github/$path/pipeline" -H "circle-token: $CIRCLECI_TOKEN" |\
        jq '.items | .[] | {(.vcs.branch): (.id)} | select(has("'$branch'")) | .[] ' 2>/dev/null | head -1 | sed 's/"//g')
    [ -n "$pipeline" ] || { errcho "Cannot query circleci API"; return 1; }
    while true; do
        status=$(curl -sL "https://circleci.com/api/v2/pipeline/$pipeline/workflow" -H "circle-token: $CIRCLECI_TOKEN" | jq .items[].status | sed 's/"//g')
        echo [$(date)]: $status $pipeline
        [ "$status" = "running" ] || break
        sleep 5
    done

    [ "$status" = "success" ]
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
		[[ -z $adir ]] && return 2
		the_new_dir=$adir
	fi

	# '~' has to be substituted by ${HOME}
	[[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

	#
	# Now change to the new dir and add to the top of the stack
	pushd "${the_new_dir}" > /dev/null || return 2
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
	local vmpath vmhome
	if [ "$1" = "vb" ]; then
		vmhome="$VBOXHOME"
		if [ -z "$vmhome" ]; then
			errcho "Err: Enviroment variable \$VBOXHOME is not set"
			return 2
		elif [ ! -d "$vmhome" ]; then
			errcho "Err: Enviroment variable \$VBOXHOME doesn't point to a valid directory"
			return 2
		fi
		shift
	elif [ "$1" = "vw" ]; then
		vmhome="$VMWAREHOME"
		if [ -z "$vmhome" ]; then
			errcho "Err: Enviroment variable \$VMWAREHOME is not set"
			return 2
		elif [ ! -d "$vmhome" ]; then
			errcho "Err: Enviroment variable \$VMWAREHOME doesn't point to a valid directory"
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
		errcho "Err: No VM home folder specified and the default ones could not be found"
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
					errcho "Err: No parameters passed and enviromental variables aren't set properly"
					return 1
				fi
			fi
		else
			if [ $vmpath = "vb" ] && [ -n "$VBOXHOME" ] && [ -d "$VBOXHOME" ]; then
				cd "$VBOXHOME"
			elif [ $vmpath = "vw" ] && [ -n "$VMWAREHOME" ] && [ -d "$VMWAREHOME" ]; then
				cd "$VMWAREHOME"
			else
				errcho "Err: '$1' is not a valid identifier for a VM home folder"
				return 2
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
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }


	local env
	local python_version=3.8
	local defaults=true
	while [ $# -gt 0 ]; do
		if [ "$1" = "--no-defaults" ]; then
			defaults=false
		elif [[  "$1" =~ ^[\.0-9]+$ ]]; then
			python_version=$1
		else
			env="$1"
		fi
		shift
	done

	conda config --set always_yes true
	if ! conda create -n "$env" "python=$python_version"; then
		errcho "Err: Error creating conda environment"
		return 3
	fi

	homes=$(conda config --show pkgs_dirs | grep -o '/.*/')
	if [ -z "$homes" ]; then
		errcho "W: Couldn't get conda home dirs. Not symlinking terminfo."
	else
		for home in $homes; do
			rm -rf "${home}envs/$env/share/terminfo"
			ln -sf /usr/share/terminfo "${home}envs/$env/share"
			break
		done
	fi

	conda deactivate
	conda activate "$env"
	pip install -U pip
	$defaults && pip install neovim ptpython flake8 pylint jedi black
	if [ -f setup.py ]; then
		pip install -e.
	elif [ -f requirements.txt ]; then
		pip install -rrequirements.txt
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
			errcho "Err: Program '$2' is not installed"
			return 3
		fi
	fi

	local usage="Usage: ${FUNCNAME[0]} <list-of-files>"
	[[ $# -lt 2 ]] && { errcho "$usage"; return 1; }
	for name in "$@"; do
		if [ -d "$name" ]; then
			errcho "Err: $name is a directory"
			return 2
		elif [ ! -f "$name" ]; then
			errcho "Err: File '$name' does not exist"
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

	[ -z $difview ] && { errcho "Err: Couldn't find a diff viewing program. Please specify it with -m"; return 1; }

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
	[ $# = 1 ] && errcho "W: Couldn't handle last argument '$1'"
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

	[[ $# -lt 2 ]] && { errcho "$usage"; return 1; }

	if  ( [ -z "$VBOXHOME" ]   || [ ! -d "$VBOXHOME" ]  ) &&\
		( [ -z "$VMWAREHOME" ] || [ ! -d "$VMWAREHOME" ]); then
		errcho 'Err: Could not find the VMs folder. Check that the enviromental variables\
			$VBOXHOME or $VMWAREHOME are set and point to valid paths'
		return 1
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
	_findvm $vmhome "$1"
	ret=$?
	if [ $ret = 0 ]; then
		local target="$vm/Shared"
		shift
		files=( "$@" )
	elif [ $ret -lt 3 ]; then
		_findvm $vmhome "$last"
		local ret=$?
		if [ $ret = 0 ]; then
			target="$vm/Shared"
			files=( "$@" )
			unset "files[${#files[@]}-1]"
		else
			return $ret
		fi
	elif [ $ret -ge 3 ]; then
		return $ret #An error message should have been printed already
	fi

	# If we found the vm folder, but there's not a subfolder called 'Shared'
	if [ ! -d "$target" ]; then
		errcho "W: Had to create the folder called Shared. The folder sharing mechanism may not be set up"
		mkdir "$target"
	fi

	#We should have at least the -r switch right now.
	cmmd="cp -$switches " #Notice the blank space at the end
	for file in "${files[@]}"; do
		cmmd+="'$file' "
	done
	cmmd+="'$target'"
	eval $cmmd

	return 0
}

# Create and swapon a new swapfile with the specified size in GB
createswap() {
	local swapfile=/swapfile
	local size=8
	local force=false
	while [ $# -ge 1 ]; do
		if [[ "$1" =~ ^[0-9]+$ ]]; then
			size=$1
		elif [ "$1" = "-f" ]; then
			force=true
		else
			swapfile=$1
			if [ -f "$swapfile" ]; then
				errcho "Err: '$swapfile' already exists"
				return 2
			fi
		fi
		shift
	done

	if ! $force; then
		swaps="$(swapon --noheadings --show=type,name | grep 'file' | cut -d' ' -f2- | paste -sd ',' -)"
		if [ -n "$swaps" ]; then
			errcho "Err: You are already swapping on: $swaps"
			return 3
		fi
	fi

	echo "Creating a ${size}GB swapfile on $swapfile"
	sudo dd if=/dev/zero of="$swapfile" status=none bs=512MiB count=$((size*2)) || return 3
	sudo chmod 0600 "$swapfile" || return 3
	sudo mkswap "$swapfile" >/dev/null || return 3
	sudo swapon "$swapfile" || return 3
}

# Dump the contents of a folder into the its parent directory and delete it afterwards.
dump() {
	aggressive=false
	[ "$1" = "-a" ] && { aggressive=true; shift; }

	local usage="Usage: ${FUNCNAME[0]} <dir>"
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }
	local target="$1"

	if [ "$(readlink -f "$target")" = "$PWD" ]; then
		target="$PWD"
		cd ..
	fi
	if [ ! -d "$target" ]; then
		errcho "Err: The specified path does not exist"
		return 2
	fi

	local findopts
	if $aggressive; then
		findopts="-depth -mindepth 1 -type f "
	else
		findopts="-mindepth 1 -maxdepth 1 "
	fi

	local file dest
	dest="$PWD"
	find "$target" $findopts -print0 | xargs -0 -I % bash -c "[ -e '%' ] && mv '%' '$dest'"
	ret=$?
	[ $ret = 0 ] && rm -rf "$target"
	return $ret
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
					errcho "Err: Directory $OPTARG does not exist"
					return 2
				fi;;
			m)
				depth=$OPTARG
				local isnum='^[0-9]+$'
				if ! [[ "$depth" =~ $isnum ]]; then
					errcho "Err: Depth argument must be a number"
					errcho "$usage"
					return 1
				fi

				if [ "$depth" -lt 1 ]; then
					errcho "Err: You won't get any results with such a stupid depth"
					return 1
				fi;;
			a)
				anyfile=true;;
			c)
				count=true;;
			h)
				errcho "$usage"
				return 0;;
			\?)
				errcho "Err: Invalid option -$OPTARG"
				errcho "$usage"
				return 1;;
			:)
				errcho "Err: Option -$OPTARG requires an argument"
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

# Convenience function to echo messages to stderr
function errcho() {
	echo "$@" >&2
}

# Unmount a device and mount it in a local folder called "folder"
folder() {
	_cleanup() {
		builtin cd "$(dirname "$mp")"
		if grep -qs "$1" /proc/mounts; then
			if ! sudo umount "$1"; then
				errcho "W: Couldn't unmount $1"
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
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }

	if [ "$1" = "-o" ]; then
		[ -z "$2" ] && { printf 'No folder name provided\n%s' "$usage"; return 1; }
		local folder="$2"
		shift 2
	else
		local folder="folder"
	fi

	# If we consumed all the arguments already, it means no device name has been passed
	[ $# -lt 1 ] && { errcho "$usage"; return 1; }

	if [ "$1" = "-k" ] || [ "$1" = "kill" ]; then

		# If the mountpoint was passed to -k as a parameter use it. Otherwise we'll have to guess what the mountpoint is
		if [ -n "$2" ]; then
			[ ! -d "$2" ] && { errcho "Err: The argument given is not a folder"; return 2; }
			if ! grep -qs "$2" /proc/mounts; then
				errcho "Err: The argument given to -k is not a mountpoint"
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
					errcho "Err: No parent mountpoint or it's not one of our own."

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
							errcho "Aborted."
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
		errcho "Err: Device '$device' does not exist"
		return 2
	else
		if grep -qs "$device" /proc/mounts; then
			if ! sudo umount "$device"; then
				errcho "Err: There was an error unmounting $device. Close any application that may be using it and try again"
				return 3;
			fi
		fi

		if ! [ -d "$folder" ]; then
			if ! mkdir "$folder" && ! sudo mkdir "$folder"; then
				errcho "Err: could not create dir"
				return 3
			fi
		fi

		# Get the id's as the normal users, instead of using the sudo ones
		opts="uid=$(id -u),gid=$(id -g)"
		if ! sudo mount -o "$opts" "$device" "$folder" 2>/dev/null; then
			if ! sudo mount -o "rw" "$device" "$folder" 2>/dev/null; then
				if ! sudo mount "$device" "$folder" 2>/dev/null; then
					errcho "Err: Could not mount $device"
					rmdir "$folder"
					return 3
				else
					errcho "W: Could not mount device r-w, mounted read only"
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
					errcho "Err: Directory $OPTARG does not exist"
					return 2
				fi;;
			m)
				depth=$OPTARG
				local isnum='^[0-9]+$'
				if ! [[ "$depth" =~ $isnum ]]; then
					errcho "Err: Depth argument must be a number"
					errcho "$usage"
					return 1
				fi

				if [ "$depth" -lt 1 ]; then
					errcho "Err: You won't get any results with such a stupid depth"
					return 1
				fi;;
			a)
				anyfile=true;;
			h)
				errcho "$usage"
				return 0;;
			\?)
				errcho "Err: Invalid option -$OPTARG"
				echo "$usage"
				return 1;;
			:)
				errcho "Err: Option -$OPTARG requires an argument"
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
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }

	trap '_mp3_exit; return 3' SIGINT SIGTERM
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

			cnt=$((cnt + 1))
			shift
		done

		for i in $(seq 0 $((cnt-1))); do
			if wait ${pids[$i]}; then
				echo "${inputs[$i]} => ${outputs[$i]}"
				$remove && rm "${inputs[$i]}"
			else
				errcho "Err: There was an error converting ${inputs[$i]} to ${outputs[$i]}"
			fi
		done
	done

	[ -f "$tmp" ] && rm "$tmp"
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
			errcho "W: No config file found for '$1'. Will use default option ${config##*/}"
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


# Opens all the pdf files in the specified directory
pdfs() {
	local viewer="firefox"
	while [ $# -gt 0 ]; do
		if [ "$1" = "-v" ]; then
			if [ -z "$2" ]; then
				errcho  "Err: An argument is required for -v" 2>&1
				return 1
			else
				if ! hash "$2" 2>/dev/null; then
					errcho "Err: Program '$2' is not installed"
					return 2
				else
					viewer="$2"
					shift 2
				fi
			fi
		else
			if ! [ -d "$1" ]; then
				errcho "Err: Destination directory '$1' not found"
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
		errcho "$usage"
		return 1
	fi

	for last; do true; done

	if ! folder "$last"; then
		return $?
	fi
	dest="folder"

	# Copy stuff from the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$dest/$1" ]; then
			errcho "W: File '$1' does not exist"
		else
			if ! cp -r "$dest/$1" .; then
				errcho "W: File '$1' could not be copied"
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


# Mounts a disk, copies a set of files into it and then unmounts it.
# This is just a wrapper for the 'folder' function, so make sure that one is in you system too
push() {
	trap 'folder -k' SIGHUP SIGINT SIGTERM
	local usage="Usage: ${FUNCNAME[0]} <list-of-files> <device>"
	[[ $# -lt 2 ]] && { errcho "$usage"; return 1; }

	for last; do true; done

	if ! folder "$last"; then
		return $?
	fi

	#I had no good way to figure out the name of the mounted
	#folder, so let's assume it's the default
	dest="folder"

	# Copy stuff to the mounted folder
	# We use 1 to skip the device's name and avoid trying to copy it to itself
	while [ $# -gt 1 ]; do
		if ! [ -e "$1" ]; then
			errcho "W: File '$1' does not exist"
		else
			if ! cp -r "$1" "$dest"; then
				errcho "W: File '$1' could not be copied"
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
	[ -z "$ip" ] && { errcho "Timeout"; return 3; }

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

# Swap two files. Rename $1 to $2 and $2 to $1
swap() {
	local usage="Usage: ${FUNCNAME[0]} <file1> <file2>"
	[[ $# -lt 2 ]] && { errcho "$usage"; return 1; }

	[ ! -e "$1" ] &&  { errcho "Err: File $1 does not exist"; return 2; }
	[ ! -e "$2" ] &&  { errcho "Err: File $2 does not exist"; return 2; }

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
			errcho "W: No config file found for $1. Will use default option $default"
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

# Show a sorted list of the most used words in a document
wordCount() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }
	file=$(echo "$1" | tr -d '\\')
	[ ! -f "$file" ]  && { errcho "Err: File '$file' not found"; return 2; }

	tr -cs 'A-Za-zñáéíóúÑÁÉÍÓÚ' '\n' < "$file" | tr A-Z a-z | sort | uniq -c | sort -rn | more

	return 0
}

# Put a file inside a directory with the same name
wrap() {
	local usage="Usage: ${FUNCNAME[0]} <file>"
	[[ $# -lt 1 ]] && { errcho "$usage"; return 1; }

	[ -e "$1" ] || { errcho "Err: File '$1' doesn't exist"; return 2; }

	tmp=$(mktemp)
	rm "$tmp"
	mv "$1" "$tmp"
	mkdir -p "$1"
	mv "$tmp" "$1/$1"
}
