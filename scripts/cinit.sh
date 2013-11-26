#!/bin/bash

print_usage() {
	echo "Usage:"

	if [[ $EUID -eq 0 ]]
	then
		echo -e "\t# $0 [target directory]\n"
	else
		echo -e "\t$ $0 [target directory]\n"
	fi

	echo -e "If no directory is specified, your current directory will be assumed.\n"
	echo "Valid arguments:"
	echo -e "\t-h / --help\tDisplay help information"
}

if [ $# -eq 0 ]
then
	CDIR=`pwd`
elif [ $# -eq 1 ]
then
	if [ "$1" = "--help" -o "$1" = "-h" ]
	then
		echo -e "cinit initialises a C project root structure\n"
		print_usage
		exit 0
	fi

	CDIR=$1
else
	echo -e "ERROR: Only one directory can be specified at the time!\n"
	print_usage
	exit -1
fi

echo -e "Initialising C project in $CDIR ...\n"

if [ ! -d $CDIR ]
then
	mkdir $CDIR

	if [ $? -ne 0 ]
	then
		exit -1
	fi
elif [ "$(ls -A $CDIR)" ]
then
	echo "$CDIR is not empty."
	read -p "Do you want to continue anyway [y/N]: " -n 1 -r

	if [ ! -z $REPLY ]
	then
		echo
	fi

	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		exit 0
	fi

	echo
fi

pushd $CDIR > /dev/null
PROJECT_DIR=`pwd`
PROJECT_NAME=${PROJECT_DIR##*/}

if [ ! -d "src" ]
then
	echo "Creating directory src/ ..."
	mkdir src
	echo -e "Done!\n"

	echo "Creating file src/main.c ..."
	echo "/* Copyright (C) `date +%Y` $USERNAME" >> src/main.c
	echo " * This file is part of $PROJECT_NAME." >> src/main.c
	echo " *" >> src/main.c
	echo " * $PROJECT_NAME is free software: you can redistribute it and/or modify" >> src/main.c
	echo " * it under the terms of the GNU General Public License as published by" >> src/main.c
	echo " * the Free Software Foundation, either version 3 of the License, or" >> src/main.c
	echo " * (at your option) any later version." >> src/main.c
	echo " *" >> src/main.c
	echo " * $PROJECT_NAME is distributed in the hope that it will be useful," >> src/main.c
	echo " * but WITHOUT ANY WARRANTY; without even the implied warranty of" >> src/main.c
	echo " * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the" >> src/main.c
	echo " * GNU General Public License for more details." >> src/main.c
	echo " *" >> src/main.c
	echo " * You should have received a copy of the GNU General Public License" >> src/main.c
	echo " * along with $PROJECT_NAME.  If not, see <http://www.gnu.org/licenses/>." >> src/main.c
	echo -e " */\n" >> src/main.c
	echo -e "#include <stdio.h>\n" >> src/main.c
	echo -e "extern long long greatest(long long, long long);\n" >> src/main.c
	echo "int main()" >> src/main.c
	echo "{" >> src/main.c
	echo -e "\tprintf(\"greatest(13, 42) == %lld\\\n\", greatest(13, 42));\n" >> src/main.c
	echo -e "\treturn 0;" >> src/main.c
	echo "}" >> src/main.c
	echo -e "Done!\n"

	echo "Creating file src/greatest.asm ..."
	echo "; Copyright (C) `date +%Y` $USERNAME" >> src/greatest.asm
	echo "; This file is part of $PROJECT_NAME." >> src/greatest.asm
	echo ";" >> src/greatest.asm
	echo "; $PROJECT_NAME is free software: you can redistribute it and/or modify" >> src/greatest.asm
	echo "; it under the terms of the GNU General Public License as published by" >> src/greatest.asm
	echo "; the Free Software Foundation, either version 3 of the License, or" >> src/greatest.asm
	echo "; (at your option) any later version." >> src/greatest.asm
	echo ";" >> src/greatest.asm
	echo "; $PROJECT_NAME is distributed in the hope that it will be useful," >> src/greatest.asm
	echo "; but WITHOUT ANY WARRANTY; without even the implied warranty of" >> src/greatest.asm
	echo "; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the" >> src/greatest.asm
	echo "; GNU General Public License for more details." >> src/greatest.asm
	echo ";" >> src/greatest.asm
	echo "; You should have received a copy of the GNU General Public License" >> src/greatest.asm
	echo -e "; along with $PROJECT_NAME.  If not, see <http://www.gnu.org/licenses/>.\n" >> src/greatest.asm
	echo "global greatest" >> src/greatest.asm
	echo "greatest:" >> src/greatest.asm
	echo -e "\tcmp\trsi, rdi" >> src/greatest.asm
	echo -e "\tmov\trax, rdi" >> src/greatest.asm
	echo -e "\tcmovge\trax, rsi" >> src/greatest.asm
	echo -e "\tret" >> src/greatest.asm
	echo -e "Done!\n"
fi

if [ ! -f "build.sh" ]
then
	echo "Creating file build.sh ..."
	echo -e "#!/bin/bash\n" >> build.sh
	echo -e "AS=\"nasm\"" >> build.sh
	echo -e "CC=\"gcc\"" >> build.sh
	echo -e "LD=\"gcc\"\n" >> build.sh
	echo -e "AFLAGS=\"-f elf64\"" >> build.sh
	echo -e "CFLAGS=\"-Wall -O3\"" >> build.sh
	echo -e "LDFLAGS=\"\"\n" >> build.sh
	echo -e "SRCDIR=\"src\"" >> build.sh
	echo -e "OBJDIR=\"obj\"" >> build.sh
	echo -e "BINDIR=\"bin\"\n" >> build.sh
	echo "SOURCES=(" >> build.sh
	echo -e "\tmain.c" >> build.sh
	echo -e "\tgreatest.asm" >> build.sh
	echo -e "\t)\n" >> build.sh
	echo -e "TARGET=\"$PROJECT_NAME\"\n" >> build.sh
	echo "# Validate source files" >> build.sh
	echo -e "for srcfile in \${SOURCES[@]}" >> build.sh
	echo "do" >> build.sh
	echo -e "\tif [ ! -f \$SRCDIR/\$srcfile ]" >> build.sh
	echo -e "\tthen" >> build.sh
	echo -e "\t\techo \"File \$SRCDIR/\$srcfile does not exist\"" >> build.sh
	echo -e "\t\texit 1" >> build.sh
	echo -e "\tfi" >> build.sh
	echo -e "done\n" >> build.sh
	echo -e "if [ ! -d \$OBJDIR ]" >> build.sh
	echo "then" >> build.sh
	echo -e "\techo \"MKDIR \$OBJDIR\"" >> build.sh
	echo -e "\tmkdir \$OBJDIR" >> build.sh
	echo -e "fi\n" >> build.sh
	echo -e "CHANGES=false\n" >> build.sh
	echo -e "for srcfile in \${SOURCES[@]}" >> build.sh
	echo "do" >> build.sh
	echo -e "\tif [ -f \$OBJDIR/\${srcfile/%.*/.o} ]" >> build.sh
	echo -e "\tthen" >> build.sh
	echo -e "\t\tOBJDATE=\`stat -c %Y \$OBJDIR/\${srcfile/%.*/.o}\`" >> build.sh
	echo -e "\t\tSRCDATE=\`stat -c %Y \$SRCDIR/\$srcfile\`\n" >> build.sh
	echo -e "\t\tif [ \$OBJDATE -lt \$SRCDATE ]" >> build.sh
	echo -e "\t\tthen" >> build.sh
	echo -e "\t\t\tCOMPILE=true" >> build.sh
	echo -e "\t\t\tCHANGES=true" >> build.sh
	echo -e "\t\telse" >> build.sh
	echo -e "\t\t\tCOMPILE=false" >> build.sh
	echo -e "\t\tfi" >> build.sh
	echo -e "\telse" >> build.sh
	echo -e "\t\tCOMPILE=true" >> build.sh
	echo -e "\t\tCHANGES=true" >> build.sh
	echo -e "\tfi\n" >> build.sh
	echo -e "\tif [ \$COMPILE = true ]" >> build.sh
	echo -e "\tthen" >> build.sh
	echo -e "\t\tif [ \"\${srcfile##*.}\" = \"asm\" ]" >> build.sh
	echo -e "\t\tthen" >> build.sh
	echo -e "\t\t\techo \"AS \$SRCDIR/\$srcfile\"" >> build.sh
	echo -e "\t\t\t\$AS \$AFLAGS -o \$OBJDIR/\${srcfile/%.*/.o} \$SRCDIR/\$srcfile" >> build.sh
	echo -e "\t\telse" >> build.sh
	echo -e "\t\t\techo \"CC \$SRCDIR/\$srcfile\"" >> build.sh
	echo -e "\t\t\t\$CC -c \$CFLAGS -o \$OBJDIR/\${srcfile/%.*/.o} \$SRCDIR/\$srcfile" >> build.sh
	echo -e "\t\tfi\n" >> build.sh
	echo -e "\t\tif [ \$? -ne 0 ]" >> build.sh
	echo -e "\t\tthen" >> build.sh
	echo -e "\t\t\texit 1" >> build.sh
	echo -e "\t\tfi" >> build.sh
	echo -e "\tfi" >> build.sh
	echo -e "done\n" >> build.sh
	echo -e "if [ ! -d \$BINDIR ]" >> build.sh
	echo "then" >> build.sh
	echo -e "\techo \"MKDIR \$BINDIR\"" >> build.sh
	echo -e "\tmkdir \$BINDIR" >> build.sh
	echo -e "fi\n" >> build.sh
	echo -e "if [ \$CHANGES = true -o ! -f \$BINDIR/\$TARGET ]" >> build.sh
	echo "then" >> build.sh
	echo -e "\t# Prepend every element in array SOURCES with object directory" >> build.sh
	echo -e "\tSOURCES=( \${SOURCES[@]/#/\$OBJDIR/} )\n" >> build.sh
	echo -e "\t# Change \".*\" to \".o\" for every element in array SOURCES" >> build.sh
	echo -e "\tSOURCES=( \${SOURCES[@]/%.*/.o} )\n" >> build.sh
	echo -e "\techo \"LD \${SOURCES[@]}\"" >> build.sh
	echo -e "\t\$LD \$CFLAGS -o \$BINDIR/\$TARGET \${SOURCES[@]} \$LDFLAGS\n" >> build.sh
	echo -e "\tif [ \$? -ne 0 ]" >> build.sh
	echo -e "\tthen" >> build.sh
	echo -e "\t\texit 1" >> build.sh
	echo -e "\telse" >> build.sh
	echo -e "\t\techo \"Output located at \$BINDIR/\$TARGET\"" >> build.sh
	echo -e "\tfi" >> build.sh
	echo "else" >> build.sh
	echo -e "\techo \"Nothing to do\"" >> build.sh
	echo "fi" >> build.sh

	chmod a+x build.sh
	echo -e "Done!\n"
fi

if [ ! -f "gpl.txt" -a ! -f "COPYING" ]
then
	echo "Downloading license file ..."

	if [ "$(which wget 2> /dev/null)" ]
	then
		wget http://www.gnu.org/licenses/gpl.txt 2> /dev/null
		mv gpl.txt COPYING
	elif [ "$(which curl 2> /dev/null)" ]
	then
		curl http://www.gnu.org/licenses/gpl.txt > COPYING 2> /dev/null
	else
		echo "ERROR: wget or curl are needed to download the license"
		exit -1
	fi

	echo -e "Done!\n"
fi

if [ ! -f "README" -a ! -f "README.md" ]
then
	echo "Creating file README.md ..."

	echo "$PROJECT_NAME" >> README.md
	LEN=${#PROJECT_NAME}
	FMTSTR=""

	while [ $LEN -gt 0 ]
	do
		FMTSTR+="="
		LEN=`expr $LEN - 1`
	done
	echo "$FMTSTR" >> README.md

	echo -e "Done!\n"
fi

echo "C project successfully initialised!"

popd > /dev/null
