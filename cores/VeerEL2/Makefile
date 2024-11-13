# SPDX-License-Identifier: Apache-2.0
# Copyright 2020 Western Digital Corporation or its affiliates.
# Copyright 2024 Antmicro <www.antmicro.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

RV_ROOT = /home/bouncmpe/cores/VeerEL2
TEST_CFLAGS = -g -gdwarf -O3 -funroll-all-loops
ABI = -mabi=ilp32
LD_ABI = $(ABI) -march=rv32im

# Allow snapshot override
target = default
snapshot = $(target)

# Allow tool override
VEER_CONFIG = ${RV_ROOT}/configs/veer.config
VERILATOR = verilator
GCC_PREFIX = riscv64-unknown-elf
BUILD_DIR = snapshots/${snapshot}
TBDIR = ${RV_ROOT}/testbench

# Override march depending on used GCC version
ifneq ($(shell which $(GCC_PREFIX)-gcc 2> /dev/null),)
	GCCVERSIONGT11 := $(shell expr `$(GCC_PREFIX)-gcc -dumpversion | cut -f1 -d.` \>= 11)
	ifeq "$(GCCVERSIONGT11)" "1"
		CC_ABI = $(ABI) -march=rv32imc_zicsr_zifencei_zba_zbb_zbc_zbs;
	else
		CC_ABI = $(ABI) -march=rv32im
	endif
endif

VERILATOR_SKIP_WARNINGS = -Wno-IMPLICITSTATIC -Wno-TIMESCALEMOD -Wno-ASCRANGE \
	-Wno-CASEINCOMPLETE -Wno-INITIALDLY -Wno-WIDTH -Wno-UNOPTFLAT

# Define test name
TEST = hello_world
TEST_DIR = /workspaces/labs344/programs
HEX_DIR = ${TBDIR}/hex
OFILES = $(TEST).o

ifdef assert
 ASSERT_DEFINES = +define+RV_ASSERT_ON
endif

# provide specific link file
ifeq (,$(wildcard $(TEST_DIR)/$(TEST).ld))
	LINK = $(BUILD_DIR)/link.ld
else
	LINK = $(TEST_DIR)/$(TEST).ld
endif

VPATH = $(TEST_DIR) $(BUILD_DIR) $(TBDIR)

-include $(TEST_DIR)/$(TEST).mki

# Testbench DPI sources
TB_DPI_SRCS = jtagdpi/jtagdpi.c \
              tcp_server/tcp_server.c

TB_DPI_INCS := $(addprefix -I$(TBDIR)/,$(dir $(TB_DPI_SRCS)))
# Add testbench include paths
CFLAGS += $(TB_DPI_INCS)

TB_DPI_SRCS := $(addprefix $(TBDIR)/,$(TB_DPI_SRCS))

# Testbench sources
TB_VERILATOR_SRCS = $(TBDIR)/test_tb_top.cpp $(TB_DPI_SRCS)

TBFILES = $(TBDIR)/tb_top_pkg.sv \
          $(TBDIR)/tb_top.sv \
          $(TBDIR)/ahb_sif.sv \
          $(TBDIR)/jtagdpi/jtagdpi.sv \
          $(TBDIR)/ahb_lite_2to1_mux.sv

defines  = $(BUILD_DIR)/common_defines.vh
defines += ${RV_ROOT}/design/include/el2_def.sv
defines += $(BUILD_DIR)/el2_pdef.vh
includes = -I${BUILD_DIR} -I$(TBDIR)/axi4_mux

# Verilator supports only C++14 and newer
CFLAGS += -std=c++17

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O3"

# Targets
all: clean verilator

clean:
	rm -rf *.log *.s *.hex *.dis *.tbl irun* vcs* simv* *.map snapshots veer* \
	verilator* *.elf obj* *.o *.sym ucli.key vc_hdrs.h csrc *.csv work \
	dataset.asdb library.cfg vsimsa.cfg riviera-build wave.asdb

############ Model Builds ###############################

# If define files do not exist, then run veer.config.
${BUILD_DIR}/defines.h:
	BUILD_PATH=${BUILD_DIR} ${RV_ROOT}/configs/veer.config -target=$(target) $(CONF_PARAMS)

verilator-build: ${TBFILES} ${BUILD_DIR}/defines.h $(TB_VERILATOR_SRCS)
	RV_ROOT=${RV_ROOT} $(VERILATOR)  --cc -CFLAGS "${CFLAGS}" $(defines) \
	  $(includes) -I${RV_ROOT}/testbench -f ${RV_ROOT}/testbench/flist \
	  $(VERILATOR_SKIP_WARNINGS) ${TBFILES} --top-module tb_top \
	  -exe $(TB_VERILATOR_SRCS) --autoflush --timing --trace --timescale 1ns/100ps
	cp ${RV_ROOT}/testbench/test_tb_top.cpp obj_dir/
	$(MAKE) -e -C obj_dir/ -f Vtb_top.mk $(VERILATOR_MAKE_FLAGS)
	touch verilator-build

############ TEST Simulation ###############################

verilator: program.hex verilator-build
	timeout 1s "./obj_dir/Vtb_top"

############ TEST build ###############################

program.hex: $(OFILES) ${BUILD_DIR}/defines.h
	@echo Building $(TEST)
	$(GCC_PREFIX)-gcc $(LD_ABI) --verbose -Wl,-Map=$(TEST).map -T$(LINK) $(TEST_LIBS) -nostdlib $(OFILES) -o $(TEST).elf
	$(GCC_PREFIX)-objcopy -O verilog  $(TEST).elf program.hex
	$(GCC_PREFIX)-objdump -S  $(TEST).elf > $(TEST).dis
	$(GCC_PREFIX)-nm -B -n $(TEST).elf > $(TEST).sym
	@echo Completed building $(TEST)

%.o : %.s ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-cpp -I${BUILD_DIR}  $<  > $*.cpp.s
	$(GCC_PREFIX)-as ${CC_ABI} $*.cpp.s -o $@

%.o : %.c ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-gcc ${includes} ${TEST_CFLAGS} -DCOMPILER_FLAGS="\"${TEST_CFLAGS}\"" ${CC_ABI} -c $< -o $@

view:
	gtkwave sim.vcd -T default_wave.tcl

.PHONY: clean verilator view

