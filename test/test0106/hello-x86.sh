#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
## Copyright (C) 2021 deesix <deesix@tuta.io>
## This file is part of M2-Planet.
##
## M2-Planet is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## M2-Planet is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with M2-Planet.  If not, see <http://www.gnu.org/licenses/>.

set -ex

ARCH="x86"
TMPDIR="test/test0106/tmp-${ARCH}"

mkdir -p ${TMPDIR}

# Build the test
bin/M2-Planet \
	--architecture ${ARCH} \
	-f M2libc/${ARCH}/Linux/unistd.h \
	-f M2libc/stdlib.c \
	-f M2libc/${ARCH}/Linux/fcntl.h \
	-f M2libc/stdio.c \
	-f test/test0106/cc500.c \
	-o ${TMPDIR}/cc0.M1 \
	|| exit 1

# Macro assemble with libc written in M1-Macro
M1 \
	-f M2libc/${ARCH}/${ARCH}_defs.M1 \
	-f M2libc/${ARCH}/libc-full.M1 \
	-f ${TMPDIR}/cc0.M1 \
	--little-endian \
	--architecture ${ARCH} \
	-o ${TMPDIR}/cc0.hex2 \
	|| exit 2

# Resolve all linkages
hex2 \
	-f M2libc/${ARCH}/ELF-${ARCH}.hex2 \
	-f ${TMPDIR}/cc0.hex2 \
	--little-endian \
	--architecture ${ARCH} \
	--base-address 0x8048000 \
	-o test/results/test0106-${ARCH}-binary \
	|| exit 3

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "${ARCH}" ]
then
	. ./sha256.sh
	# Verify that the compiled program can compile itself
	./test/results/test0106-${ARCH}-binary < test/test0106/cc500.c >| test/test0106/cc1 || exit 4
	out=$(sha256_check test/test0106/proof0.answer)
	[ "$out" = "test/test0106/cc1: OK" ] || exit 5

	# Make it executable
	chmod u+x test/test0106/cc1

	# Verify that the result of it compiling itself can compile itself
	./test/test0106/cc1 < test/test0106/cc500.c >| test/test0106/cc2 || exit 6
	out=$(sha256_check test/test0106/proof1.answer)
	[ "$out" = "test/test0106/cc2: OK" ] || exit 7
fi
exit 0
