#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

setup(){
	temp="$(mktemp -d)"
	cd $temp
}

teardown() {
	cd "$HOME"
	[ -d "$temp" ] && rm -rf "$temp"
}

@test "Run c" {
	hash gcc || skip "Gcc is not installed"
	cat > test.c <<EOF
	#include <stdio.h>
	int main() {
		printf ("Hello world\n");
		return 0;
	}
EOF

	run brun test.c
	[ "$output" = "Hello world" ]
}

@test "Run cpp" {
	hash g++ || skip "G++ is not installed"
	cat > test.cpp <<EOF
#include <iostream>
int main() {
	std::cout << "Hello world\n";
	return 0;
}
EOF

	run brun test.cpp
	[ "$output" = "Hello world" ]
}

@test "Run java" {
	hash javac && hash java || skip "Java is not installed"
	cat > Test.java <<EOF
	public class Test {
		public static void main (String  [] args){
			System.out.println("Hello world");
		}
	}
EOF

	run brun Test.java
	[ "$output" = "Hello world" ]
}

@test "Run sh" {
	cat >test.sh<<EOF
	echo "Hello world"
EOF
	run brun test.sh
	[ "$output" = "Hello world" ]
}

@test "Run c with arguments" {
	hash gcc || skip "Gcc is not installed"
	cat > test.c <<EOF
	#include <stdio.h>
	int main(int argc, char **argv) {
		int i;
		for (i=1; i<argc; i++){
			printf ("%s", argv[i]);
			if (i<argc-1) printf (" ");
		}
		printf("\n");
		return 0;
	}
EOF

	run brun test.c "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run cpp with arguments" {
	hash g++ || skip "G++ is not installed"
	cat > test.cpp <<EOF
	#include <iostream>
	int main(int argc, char **argv) {
		for (int i=1; i<argc; i++){
			std::cout << argv[i];
			if (i<argc-1) std::cout << " ";
		}
		std::cout << std::endl;
		return 0;
	}
EOF

	run brun test.cpp "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run java with arguments" {
	hash javac && hash java || skip "Java is not installed"
	cat > Test.java <<EOF
	public class Test {
		public static void main (String  [] args){
			for (int i=0; i<args.length; i++){
				System.out.print(args[i]);
				if (i<args.length-1)
					System.out.print(' ');
			}
			System.out.print('\n');
		}
	}
EOF

	run brun Test.java "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run sh with arguments" {
	cat > test.sh <<EOF
	echo \$*
EOF

	run brun test.sh "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run c with compiler options" {
	hash gcc || skip "Gcc is not installed"
	# This should give a "unused variable" warning when compiled with -Wall
	cat > test.c <<EOF
int main() {
	int i=0;
	return 0;
}
EOF

	run brun -Wall test.c
	[ -n "$output" ]
}

@test "Run c++ with compiler options" {
	hash g++ || skip "G++ is not installed"
	# This should give a "unused variable" warning when compiled with -Wall
	cat > test.cpp <<EOF
int main() {
	int i=0;
	return 0;
}
EOF

	run brun -Wall -Wextra test.cpp
	[ -n "$output" ]
}

@test "Run c with multiple files" {
	hash gcc || skip "Gcc is not installed"
	cat > test.c <<EOF
#include <stdio.h>

void hello() {
	printf ("Hello world\n");
}
EOF
	cat > test2.c <<EOF
void hello();

int main() {
	hello();
	return 0;
}
EOF

	run brun test2.c test.c
	[ "$output" = "Hello world" ]
}

@test "Run c++ with multiple files" {
	hash g++ || skip "G++ is not installed"
	cat > test.cpp <<EOF
#include <iostream>

void hello() {
	std::cout << "Hello world\n";
}
EOF
	cat > test2.cpp <<EOF
void hello();

int main() {
	hello();
	return 0;
}
EOF

	run brun test2.cpp test.cpp
	[ "$output" = "Hello world" ]
}

@test "Run java with multiple files" {
	hash javac && hash java || skip "Java is not installed"
	mkdir test
	cat > test/Test.java <<EOF
package test;

import test.Test2;

public class Test {
	public static void main(String[] args){
		Test2 test = new Test2();
		test.run();
	}
}
EOF

	cat > test/Test2.java <<EOF
package test;

public class Test2 {
	public Test2(){}

	public void run() {
		System.out.println( "Hello world" );
	}
}
EOF

	run brun test/*java
	[ "$output" = "Hello world" ]
}

@test "Run c with compiler args, multiple files, program args" {
	hash gcc || skip "Gcc is not installed"
	cat > test.c <<EOF
#include <stdio.h>

void print(const char *msg) {
	printf ("%s", msg);
}
EOF
	cat > test2.c <<EOF
#include <math.h>
void print(const char*);

int main(int argc, char **argv) {
	int i=1;
	for(; i<argc; i++){
		print(argv[i]);
		if (i < argc-1) print(" ");
	}
	print("\n");
	sqrt(3.);
	return 0;
}
EOF

	run brun -Wall -lm test2.c test.c Hello world
	[ "$output" = "Hello world" ]
}

@test "Run c++ with compiler args, multiple files, program args" {
	hash g++ || skip "G++ is not installed"
	cat > test.cpp <<EOF
#include <iostream>

void print(const std::string &msg) {
	std::cout << msg;
}
EOF
	cat > test2.cpp <<EOF
#include <string>
#include <cmath>
void print(const std::string&);

int main(int argc, char **argv) {
	int i=1;
	float j=3.0;
	for(; i<argc; i++){
		print(std::string(argv[i]));
		if (i < argc-1) print(" ");
	}
	print("\n");
	sqrt(j);
	return 0;
}
EOF

	run brun -Wall -lm test2.cpp test.cpp Hello world
	[ "$output" = "Hello world" ]
}

@test "Run java with multiple files, program args" {
	hash javac && hash java || skip "Java is not installed"
	mkdir test
	cat > test/Test.java <<EOF
package test;

import test.Test2;

public class Test {
	public static void main(String[] args){
		Test2 test = new Test2();
		test.run(args);
	}
}
EOF

	cat > test/Test2.java <<EOF
package test;

public class Test2 {
	public Test2(){}

	public void run(String[] args) {
		for (String s : args){
			System.out.print(s);
			if (!s.equals(args[args.length-1]))
				System.out.print(" ");
		}
		System.out.print("\n");
	}
}
EOF

	run brun test/*java Hello world
	[ "$output" = "Hello world" ]
}
