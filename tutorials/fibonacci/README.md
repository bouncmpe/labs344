# Simulate your first RISC-V program

This tutorial shows how to simulate a RISC-V assembly program using our development environment and tools. For this purpose, please find the assembly program `fibonacci.s` written in the RISC-V assembly language in this directory. We will simulate this and compute the first twelve elements of the Fibonacci sequence: `0`, `1`, `1`, `2`, `3`, `5`, `8`, `13`, `21`, `34`, `55`, `89`. 

## Assemble and Link

To create an executable from RISC-V assembly code,
 we utilize the RISC-V toolchain. This toolchain includes RISC-V versions of the standard GNU tools like `gcc`, `as`, `ld`. The prefix `riscv64-unknown-elf-` indicates that these tools are designed for RISC-V architectures, distinguishing them from their counterparts for `x86` or `arm` processors. The usage of the toolchain is generally similar to that of other compiler toolchains.

> [!IMPORTANT]
> Investigate the meaning of the epithet `unknown-elf`. What other options are available,
 and why is `unknown-elf` used in our context?

We begin by using the following command to compile 
`fibonacci.s` into the executable `fibonacci.elf`:

```
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -o fibonacci.elf -nostdlib -T linker.ld fibonacci.s
```

Note the use of the `-nostdlib` flag in the compilation step. This flag prevents the linker from automatically including the standard C library, which can introduce unnecessary symbols and clutter our object files and executables. For our current purpose of focusing on the assembly code itself, linking with the standard library is not required. However, feel free to experiment with removing the `-nostdlib` flag later to observe the impact of including the standard library.

We also explicitly supply our own linker script `linker.ld`. The linker script controls how different sections of the program (.text, .data, .bss, etc.) are mapped into memory. If we do not include the custom linker script, the default linker would load the program at address `0x10000`. However, Spike expects the program to reside starting from `0x80000000`. Thus, if the program is not linked accordingly, Spike would raise an error.

> [!IMPORTANT]
> Investigate the functionality of other options passed to the compiler.

The `fibonacci.elf` is a binary executable in the ELF format, containing the RISC-V machine code that calculates Fibonacci numbers. To analyze its contents in a human-readable form, we'll disassemble it in the following section.

## Disassemble the ELF

Disassembling the ELF file means we convert the binary file `fibonacci.elf` in a human-readable textual file. We can disassemble ELF objects and executable using the program `objdump` as follows:

```bash
riscv64-unknown-elf-objdump --disassemble fibonacci.elf > fibonacci.txt
```

Now check out the contents of `fibonacci.txt`, which is a plain text file, in your text editor. It should look like this:

```
fibonacci.elf:     file format elf32-littleriscv

Disassembly of section .text:

80000000 <_start>:
80000000:	00010297          	auipc	t0,0x10
80000004:	00028293          	mv	t0,t0
80000008:	00a00313          	li	t1,10
8000000c:	00000393          	li	t2,0
80000010:	00100e13          	li	t3,1
80000014:	0072a023          	sw	t2,0(t0) # 80010000 <_data_end>
80000018:	00428293          	addi	t0,t0,4
8000001c:	01c2a023          	sw	t3,0(t0)

80000020 <LOOP>:
80000020:	02030063          	beqz	t1,80000040 <DONE>
80000024:	007e0eb3          	add	t4,t3,t2
80000028:	00428293          	addi	t0,t0,4
8000002c:	01d2a023          	sw	t4,0(t0)
80000030:	000e0393          	mv	t2,t3
80000034:	000e8e13          	mv	t3,t4
80000038:	fff30313          	addi	t1,t1,-1
8000003c:	fe5ff06f          	j	80000020 <LOOP>

80000040 <DONE>:
80000040:	0000006f          	j	80000040 <DONE>

```

The `fibonacci.txt` file is a disassembled version of our assembled code. It provides a more detailed view of the instructions and data, including the assigned memory addresses and the substitution of pseudo-instructions with their corresponding RISC-V machine code. These changes are performed by the assembler during the compilation process.

## Simulate using Spike

Our desktop computers typically use `x86_64` processors, which are incompatible with RISC-V executables like `fibonacci.elf`. If you have a computer equipped with a RISC-V processor, you can directly execute `fibonacci.elf` on it.

For those using `x86-64` or `arm64` processors, it is possible to simulate RISC-V executables using RISC-V ISA simulators. In our environment, we use Spike, the golden reference functional RISC-V ISA software simulator. Please check its installation by running the following command:

```bash
spike --help
```

If you see `spike` help text, everything is set up correctly.

We first use the simulator in the interactive mode, where we can instruct commands to the simulator one by one. To start the simulation of `fibonacci.elf` in the interactive mode, please run the command in your terminal as follows:

```
spike -d --isa=RV32IM fibonacci.elf
```

> [!IMPORTANT]
> Since Spike runs the program in a 64-bit core and the program is compiled for 32-bit RISC-V, we need to include `--isa=RV32IM` option to tell Spike to simulate the program on a RV32 core. 

Now you are in the interactive shell where you can give commands to the simulator. You can find the most commonly used commands for `spike` in the following table.

| Interactive commands             | Description                                                              |
|----------------------------------|--------------------------------------------------------------------------|
| `[<ENTER>]`                      | Proceed 1 steps.                                                         |
| `run [<N>]` or `r [<N>]`         | Proceed noisy execution for `N` steps, default is 1.                     |
| `rs [<N>]`                       | Resume silent execution for `N` steps, default is 1.                     |
| `reg <CORE> [<REG>]`             | Display the current content of the `REG` (all if omitted) in `CORE`      |
| `mem [<CORE>] <ADDR>`            | Display the current content of the memory location at `ADDR` in `CORE`   |
| `pc <CORE>`                      | Display current `PC` in `CORE`                                           |
| `insn <CORE>`                    | Display current instruction corresponding to `PC` in `CORE`              |
| `untiln reg <CORE> <REG> <VAL>`  | Proceed until the `REG` becomes `VAL` in `CORE`                          |
| `untiln mem <CORE> <ADDR> <VAL>` | Proceed until the `ADDR` becomes `VAL` in `CORE`                         |
| `untiln pc <CORE> <VAL>`         | Proceed until the `PC` hits `VAL` in `CORE`                              |
| `untiln insn <CORE> <VAL>`       | Proceed until the instruction corresponding to `PC` becomes `VAL`        |
| `quit`                           | Quit the simulation and interactive mode                                 |

Now we are ready to simulate our Fibonacci program. Hit `Enter` or execute `run 1` command to advance the program by one instruction. You will see the executed instruction printed in your terminal.

```
(spike)
core   0: 0x00001000 (0x00000297) auipc   t0, 0x0

(spike) run 1
core   0: 0x00001004 (0x02028593) addi    a1, t0, 32
```

Besides advancing the simulation one by one, we can also use `run [N]` command to advance it by `N` steps. Moreover, we can simulate the program until reaching a particular instruction using `untiln pc <CORE> <VAL>` command. The `VAL` is the address of the desired instruction. Let's simulate until the end of the initialization phase of our `fibonacci.elf` program by typing `untiln pc 0 0x80000020` where `0x80000020` is the address of the label `LOOP`:

```
(spike) untiln pc 0 80000020     
core   0: 0x00001008 (0xf1402573) csrr    a0, mhartid
core   0: 0x0000100c (0x0182a283) lw      t0, 24(t0)
core   0: 0x00001010 (0x00028067) jr      t0
core   0: 0x80000000 (0x00010297) auipc   t0, 0x10
core   0: 0x80000004 (0x00028293) mv      t0, t0
core   0: 0x80000008 (0x00a00313) li      t1, 10
core   0: 0x8000000c (0x00000393) li      t2, 0
core   0: 0x80000010 (0x00100e13) li      t3, 1
core   0: 0x80000014 (0x0072a023) sw      t2, 0(t0)
core   0: 0x80000018 (0x00428293) addi    t0, t0, 4
core   0: 0x8000001c (0x01c2a023) sw      t3, 0(t0)
```

At this point, we did some initialization, and let's check some values on registers. We use `reg 0 t2` and `reg 0 t3` to print the content of those registers.

```
(spike) reg 0 t2
0x00000000

(spike) reg 0 t3
0x00000001
```

Confirm that these registers are correctly initialized to `0` and `1`, corresponding to the first and second Fibonacci numbers in the hexadecimal format. 

Now we are ready to enter the loop and compute the rest of the sequence. For each loop, we can use the following sequence of commands:

```
(spike) run 1

(spike) untiln pc 0 0x80000020

(spike) reg 0 t4
```

At the end of each cycle, you should see the following Fibonacci number printed in the `t4` register. Continue the simulation until the end or use `untiln pc 0 0x80000040` to simulate until the `DONE` label. We intentionally add an infinite loop at the end where we jump into the same location and execute the same instruction repeatedly. Feel free to `run` as many times as you wish.

Now our computation is done. Remember that our program also writes the computed Fibonacci numbers into an array on the memory. Check all the Fibonacci numbers from the memory using their address values.

```
(spike) mem 0x80010000
0x00000000
(spike) mem 0x80010004
0x00000001
(spike) mem 0x80010008
0x00000001
(spike) mem 0x8001000c
0x00000002
...
(spike) mem 0x8001002c
0x00000059
```

> [!IMPORTANT]
> You can see the symbol table of `fibonacci.elf` using the `-t` flag of `riscv64-unknown-elf-objdump` command. Use this to find the address of `V` symbol and check its content using `mem` command.


The last Fibonacci number we have computed resides at the location `0x8001002c` and has a value of `0x59`, which `89` in decimal as expected. Type `quit` to end the simulation and interactive mode.
