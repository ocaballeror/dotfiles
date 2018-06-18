#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	if ! hash conda 2>/dev/null; then
		skip "Conda is not installed"
	fi

	conda_home=$(conda info -s | grep 'CONDA_ROOT' | cut -d: -f2-)
	conda_home=${conda_home#* }
	. "$conda_home/etc/profile.d/conda.sh"
}

teardown(){
	if hash conda 2>/dev/null; then
		conda deactivate
		conda env remove -n "$env"
	fi
}

# Check that the env exists and it's currently active
check_env() {
	[[ $(conda info | grep 'active environment' | cut -d: -f2-) = " $1" ]]
	home=$(conda info | grep 'active env location' | cut -d: -f2-)
	home=${home#* }
	[[ $(which python) == "$home/bin/python" ]]
	[ -f "$home/share/terminfo/r/rxvt-unicode-256color" ]
	f=$(pip freeze)
	for req in jedi flake8 ptpython; do
		echo $f | grep -q $req
	done
}

@test "Standard cenv" {
	tmp=$(mktemp)
	rm "$tmp"
	env=$(basename $tmp)
	cenv "$env"
	check_env "$env"
}

@test "Cenv with requirements" {
	tmp=$(mktemp -d)
	cd "$tmp"
	env=$(basename $tmp)
	
	echo pytz > requirements.txt
	cenv "$env"
	check_env "$env"

	# Check that the requirements were installed
	pip freeze | grep -q jedi

	cd -
	rm -rf "$tmp"
}

@test "Cenv with a different python version" {
	tmp=$(mktemp)
	rm "$tmp"
	env=$(basename $tmp)
	cenv "$env" 2.7
	check_env "$env"

	# Check the python version
	python --version 2>&1 | grep -iq "python 2.7"
}
