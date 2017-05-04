load ~/.bash_functions

setup(){
	current="$(pwd)"
	temp=$(mktemp -d)

	mkdir $temp/vbox
	mkdir $temp/vmware

	oldvbox="$VBOXHOME"
	oldvmw="$VMWAREHOME"
	export VBOXHOME="$temp/vbox"
	export VMWAREHOME="$temp/vmware"

	mkdir $VBOXHOME/arch
	mkdir $VBOXHOME/Arch
	mkdir $VMWAREHOME/arch
	mkdir $VMWAREHOME/Arch
}

teardown() {
	cd "$HOME"
	rm -rf $temp
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Basic cdvm" {
	cdvm Arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "Case sensitive cdvm" {
	cdvm arch
	[ $(pwd) = $VBOXHOME/arch ]
}

@test  "Case insensitive cdvm" {
	rm -rf $VBOXHOME/arch
	cdvm arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "vw cdvm" {
	cdvm vw arch
	[ $(pwd) = $VMWAREHOME/arch ]
}

@test "Fallback vmware for cdvm" {
	rm -rf $VBOXHOME/Arch
	cdvm arch
	[ $(pwd) = $VMWAREHOME/arch ]
}

@test "Cdvm to virtualbox home" {
	cdvm vb
	[ $(pwd) = $VBOXHOME ]
}

@test "Cdvm to vmware home" {
	cdvm vw
	[ $(pwd) = $VMWAREHOME ]
}

@test "Cdvm with no arguments" {
	cdvm 
	[ $(pwd) = $VBOXHOME ]
}

@test "Cdvm to nonexistent vm" {
	cwd="$(pwd)"
	run cdvm nonexistent
	[ $status != 0 ]
	echo "$(pwd)" > ~/out
	echo "$cwd" >> ~/out
	[ $(pwd) = $cwd ]
}
	
@test "Cdvm to nonexistent vm with nonexisting vboxhome" {
	cd /
	rm -rf $VBOXHOME
	cdvm
	[ $(pwd) = $VMWAREHOME ]
}
