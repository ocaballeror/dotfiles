load ~/.bash_functions

wsetup(){
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

wteardown() {
	cd "$HOME"
	rm -rf $temp
	export VBOXHOME="$oldvbox"
	export VMWAREHOME="$oldvmw"
}

@test "Basic cdvm" {
	wsetup
	cdvm Arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "Case sensitive cdvm" {
	cdvm arch
	[ $(pwd) = $VBOXHOME/arch ]
}

@test  "Case insensitive cdvm" {
	rmdir $VBOXHOME/arch
	cdvm arch
	[ $(pwd) = $VBOXHOME/Arch ]
}

@test "vw cdvm" {
	cdvm vw arch
	[ $(pwd) = $VMWAREHOME/arch ]
}

@test "Fallback vmware for cdvm" {
	rmdir $VBOXHOME/Arch
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
	cd /
	cdvm nonexistent
	[ $(pwd) = $VBOXHOME ]
}
	
@test "Cdvm to nonexistent vm with nonexisting vboxhome" {
	cd /
	rmdir $VBOXHOME
	cdvm
	[ $(pwd) = $VMWAREHOME ]

	wteardown
}
