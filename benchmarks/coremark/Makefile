# Wally Coremark Makefile
# SPDX-FileCopyrightText: 2022 Daniel Torres, David Harris
# SPDX-FileCopyrightText: 2025 Dogan Ulus
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

.PHONY: clean

WALLY ?= /opt/openhwgroup/cvw
LABS344_DIR ?= /workspaces/labs344

COREMARK_BASEDIR = ${WALLY}/addins/coremark
COREMARK_PORTDIR = ${WALLY}/benchmarks/coremark/riscv64-baremetal
COREMARK_TMPDIR  = ${LABS344_DIR}/benchmarks/coremark/work

CC = riscv64-unknown-elf-gcc
LD = riscv64-unknown-elf-ld

ARCH   := rv32gc
XLEN   := $(if $(findstring 32,$(ARCH)),32,64)
ABI    := $(if $(findstring 64,$(XLEN)),lp64,ilp32)
CONFIG := rv$(XLEN)gc

sources=$(COREMARK_BASEDIR)/core_main.c $(COREMARK_BASEDIR)/core_list_join.c $(COREMARK_BASEDIR)/coremark.h  \
	$(COREMARK_BASEDIR)/core_matrix.c $(COREMARK_BASEDIR)/core_state.c $(COREMARK_BASEDIR)/core_util.c \
	$(COREMARK_PORTDIR)/core_portme.h $(COREMARK_PORTDIR)/core_portme.c $(COREMARK_PORTDIR)/core_portme.mak \
	$(COREMARK_PORTDIR)/crt.S $(COREMARK_PORTDIR)/encoding.h $(COREMARK_PORTDIR)/util.h $(COREMARK_PORTDIR)/syscalls.c

PORT_CFLAGS = -g -mabi=$(ABI) -march=$(ARCH) -static -falign-functions=16 \
	-mbranch-cost=1 -DSKIP_DEFAULT_MEMSET -mtune=sifive-3-series -O3 -finline-functions -falign-jumps=4 \
	-fno-delete-null-pointer-checks -fno-rename-registers --param=loop-max-datarefs-for-datadeps=0 \
	-funroll-all-loops --param=uninlined-function-insns=8 -fno-tree-vrp -fwrapv -fipa-pta \
	-nostdlib -nostartfiles -ffreestanding -mstrict-align \
	-DTOTAL_DATA_SIZE=2000 -DMAIN_HAS_NOARGC=1 -DPERFORMANCE_RUN=1 -DITERATIONS=10 -DXLEN=$(XLEN) 

all: $(COREMARK_TMPDIR)/coremark.bare.riscv.elf.memfile

run: $(COREMARK_TMPDIR)/coremark.bare.riscv.elf.memfile
	make -C ${LABS344_DIR}/sim/verilator WALLYCONF=${CONFIG} TEST=coremark TESTBENCH=testbench 

$(COREMARK_TMPDIR)/coremark.bare.riscv.elf.memfile: $(COREMARK_TMPDIR)/coremark.bare.riscv
	riscv64-unknown-elf-objdump -D $< > $<.elf.objdump
	riscv64-unknown-elf-elf2hex --bit-width $(XLEN) --input $< --output $@
	${WALLY}/bin/extractFunctionRadix.sh $<.elf.objdump

$(COREMARK_TMPDIR)/coremark.bare.riscv: $(sources) Makefile
	$(MAKE) -C $(COREMARK_BASEDIR) PORT_DIR=$(COREMARK_PORTDIR) compile RISCV=$(RISCV) XCFLAGS="$(PORT_CFLAGS)"
	mkdir -p $(COREMARK_TMPDIR)
	mv $(COREMARK_BASEDIR)/coremark.bare.riscv $(COREMARK_TMPDIR)

clean:
	rm -rf $(COREMARK_TMPDIR)
	$(MAKE) -C $(COREMARK_BASEDIR) clean
	$(MAKE) -C ${LABS344_DIR}/sim/verilator clean
