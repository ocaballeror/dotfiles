#!/usr/bin/env bats

load $BATS_TEST_DIRNAME/../../bash/.bash_functions

temp="$(mktemp -d)"
cd $temp

@test "Run c" {
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
	cat > test.cpp <<EOF
	#include <iostream>
	int main() {
		std::cout << "Hello world\n";
		return 0;
	}
EOF

	run brun test.c
	[ "$output" = "Hello world" ]
}

@test "Run java" {
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
	cat > test.sh <<EOF
	echo "Hello world"
EOF	

	run brun test.sh
	[ "$output" = "Hello world" ]
}

@test "Run c with arguments" {
	cat > test.c <<EOF
	#include <stdio.h>
	int main(int argc, char **argv) {
		int i;
		for (i=1; i<=argc; i++){
			printf ("%s", argv[i]);
			if (i<argc) printf (" ");
		} 
		printf("\n");
		return 0;
	}
EOF

	run brun test.c "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run cpp with arguments" {
	cat > test.cpp <<EOF
	#include <iostream>
	int main(int argc, char **argv) {
		for (int i=1; i<=argc; i++){
			std::cout << argv[i];
			if (i<argc) std::cout << " ";
		} 
		std::cout << std::endl;
		return 0;
	}
EOF

	run brun test.c "Hello world"
	[ "$output" = "Hello world" ]
}

@test "Run java with arguments" {
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

cd "$HOME"
[ -d "$temp" ] && rm -rf "$temp"
