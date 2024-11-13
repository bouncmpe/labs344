# SPDX-License-Identifier: Apache-2.0
# Copyright 2020 Western Digital Corporation or its affiliates.
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
RV_ROOT = /home/bouncmpe/cores/VeerEH1
CONF_PARAMS = -set iccm_enable
TEST_CFLAGS = -g -O3 -funroll-all-loops
ABI = -mabi=ilp32 -march=rv32im

# Allow snapshot override
target = default
snapshot = $(target)

# Allow tool override
VEER_CONFIG = ${RV_ROOT}/configs/veer.config
IRUN = xrun
VCS = vcs
VERILATOR = verilator
VLOG = qverilog
RIVIERA = riviera
GCC_PREFIX = riscv64-unknown-elf
BUILD_DIR = snapshots/${snapshot}
TBDIR = ${RV_ROOT}/testbench

# Define default test name
TEST = hello_world

# Define default test directory
TEST_DIR = /workspaces/labs344/programs
HEX_DIR = $(TBDIR)/hex
ifneq (,$(wildcard $(TBDIR)/tests/$(TEST)))
        TEST_DIR = $(TBDIR)/tests/$(TEST)
endif

# provide specific link file
ifeq (,$(wildcard $(TEST_DIR)/$(TEST).ld))
	LINK = $(TBDIR)/link.ld
else
	LINK = $(TEST_DIR)/$(TEST).ld
endif

OFILES = $(TEST).o

-include $(TEST_DIR)/$(TEST).mki

VPATH = $(TEST_DIR) $(BUILD_DIR) $(TBDIR)
TBFILES = $(TBDIR)/tb_top.sv $(TBDIR)/ahb_sif.sv

defines = $(BUILD_DIR)/common_defines.vh ${RV_ROOT}/design/include/veer_types.sv
includes = -I${RV_ROOT}/design/include -I${RV_ROOT}/design/lib  -I${BUILD_DIR}

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
	verilator* *.elf obj* *.o ucli.key vc_hdrs.h csrc *.csv \
	work dataset.asdb  library.cfg

# If define files do not exist, then run veer.config.
${BUILD_DIR}/defines.h :
	BUILD_PATH=${BUILD_DIR} ${VEER_CONFIG} -target=$(target) $(CONF_PARAMS)

##################### Verilog Builds #####################################

verilator-build: ${TBFILES} ${BUILD_DIR}/defines.h test_tb_top.cpp
	echo '`undef ASSERT_ON' >> ${BUILD_DIR}/common_defines.vh
	RV_ROOT=${RV_ROOT} $(VERILATOR) --cc -CFLAGS ${CFLAGS} $(defines) $(includes) \
                -Wno-UNOPTFLAT \
                -I${RV_ROOT}/testbench \
				-f ${RV_ROOT}/testbench/flist \
                ${TBFILES} \
                --top-module tb_top -exe test_tb_top.cpp \
				--autoflush --timing --trace --timescale 1ns/100ps
	cp ${RV_ROOT}/testbench/test_tb_top.cpp obj_dir
	$(MAKE) -j -C obj_dir/ -f Vtb_top.mk $(VERILATOR_MAKE_FLAGS)
	touch verilator-build

##################### Simulation Runs #####################################

verilator: program.hex verilator-build
	timeout 1s "./obj_dir/Vtb_top"

##################### Test Build #####################################

program.hex: $(OFILES) $(LINK)
	@echo Building $(TEST)
	$(GCC_PREFIX)-gcc $(ABI) -Wl,-Map=$(TEST).map -T$(LINK) -o $(TEST).elf -nostdlib $(OFILES) $(TEST_LIBS)
	$(GCC_PREFIX)-objcopy -O verilog $(TEST).elf program.hex
	$(GCC_PREFIX)-objdump -S  $(TEST).elf > $(TEST).dis
	@echo Completed building $(TEST)

%.o : %.s ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-cpp -I${BUILD_DIR}  $<  > $*.cpp.s
	$(GCC_PREFIX)-as $(ABI) $*.cpp.s -o $@


%.o : %.c ${BUILD_DIR}/defines.h
	$(GCC_PREFIX)-gcc -I${BUILD_DIR} ${TEST_CFLAGS} ${ABI} -nostdlib -c $< -o $@

view:
	gtkwave sim.vcd -T default_wave.tcl

.PHONY: clean verilator view