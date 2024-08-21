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
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -o fibonacci.elf -nostdlib fibonacci.s
```

Note the use of the `-nostdlib` flag in the compilation step. This flag prevents the linker from automatically including the standard C library, which can introduce unnecessary symbols and clutter our object files and executables. For our current purpose of focusing on the assembly code itself, linking with the standard library is not required. However, feel free to experiment with removing the `-nostdlib` flag later to observe the impact of including the standard library.

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

00010094 <_start>:
   10094:	00001297          	auipc	t0,0x1
   10098:	04428293          	addi	t0,t0,68 # 110d8 <__DATA_BEGIN__>
   1009c:	00a00313          	li	t1,10
   100a0:	00000393          	li	t2,0
   100a4:	00100e13          	li	t3,1
   100a8:	0072a023          	sw	t2,0(t0)
   100ac:	00428293          	addi	t0,t0,4
   100b0:	01c2a023          	sw	t3,0(t0)

000100b4 <LOOP>:
   100b4:	02030063          	beqz	t1,100d4 <DONE>
   100b8:	007e0eb3          	add	t4,t3,t2
   100bc:	00428293          	addi	t0,t0,4
   100c0:	01d2a023          	sw	t4,0(t0)
   100c4:	000e0393          	mv	t2,t3
   100c8:	000e8e13          	mv	t3,t4
   100cc:	fff30313          	addi	t1,t1,-1
   100d0:	fe5ff06f          	j	100b4 <LOOP>

000100d4 <DONE>:
   100d4:	0000006f          	j	100d4 <DONE>
```

The `fibonacci.txt` file is a disassembled version of our assembled code. It provides a more detailed view of the instructions and data, including the assigned memory addresses and the substitution of pseudo-instructions with their corresponding RISC-V machine code. These changes are performed by the assembler during the compilation process.

## Simulate using Whisper

Our desktop computers typically use `x86-64` processors, which are incompatible with RISC-V executables like `fibonacci.elf`. If you have a computer equipped with a RISC-V processor, you can directly execute `fibonacci.elf` on it.

For those using `x86-64` or `arm64` processors, it is possible to simulate RISC-V executables using RISC-V ISA simulators. The `whisper` simulator is a production-grade RISC-V ISA simulator available in our lab's development environment. Please check its installation by running the following command:

```bash
whisper --help
```

If you see `whisper` help text, everything is set up correctly.

We first use the simulator in the interactive mode, where we can instruct commands to the simulator one by one. To start the simulation of `fibonacci.elf` in the interactive mode, please run the command in your terminal as follows:

```
whisper --interactive fibonacci.elf
```

Now you are in the interactive mode where you can give commands to the simulator. You can find the most commonly used commands for `whisper` in the following table.

| Interactive commands | Description                                                |
|----------------------|------------------------------------------------------------|
| `step [<N>]`         | Proceed `N` steps, default is 1.                           |
| `until <ADDR>`       | Proceed until reaching the address `ADDR`                  |
| `peek r <REG>`       | Print the current content of the register `REG`            |
| `peek m <ADDR>`      | Print the current content of the memory location at `ADDR` |
| `quit`               | Quit the simulation and interactive mode                   |

You can find other commands for `whisper` as listed in their docs [here](https://github.com/chipsalliance/VeeR-ISS).

Now we are ready to simulate our Fibonacci program. Execute `step` command to advance the program by one instruction. You will see the executed instruction printed in your terminal.

```
whisper> step
#1 0 00010094 00001297 r 05         00011094  auipc    x5, 0x1

whisper> step 
#2 0 00010098 04428293 r 05         000110d8  addi     x5, x5, 68
```

Besides advancing the simulation one by one, we can also use `step N` command to advance it by `N` steps. Moreover, we can simulate the program until reaching a particular instruction using `until <ADDR>` command. The `ADDR` is the address of the desired instruction. Let's simulate until the end of the initialization phase of our `fibonacci.elf` program by typing `until 0x100b4` where `0x100b4` is the address of the label `LOOP`:

```
whisper> until 0x100b4
#3 0 0001009c 00a00313 r 06         0000000a  addi     x6, x0, 10
#4 0 000100a0 00000393 r 07         00000000  addi     x7, x0, 0
#5 0 000100a4 00100e13 r 1c         00000001  addi     x28, x0, 1
#6 0 000100a8 0072a023 m 000110d8   00000000  sw       x7, 0x0(x5)
#7 0 000100ac 00428293 r 05         000110dc  addi     x5, x5, 4
#8 0 000100b0 01c2a023 m 000110dc   00000001  sw       x28, 0x0(x5)
```

At this point, we did some initialization, and let's check some values on registers. We use `peek r t2` and `peek r t3` to print the content of those registers.

```
whisper> peek r t2
0x00000000
whisper> peek r t3
0x00000001
```

Confirm that these registers are correctly initialized to `0` and `1`, corresponding to the first and second Fibonacci numbers in the hexadecimal format. 

Now we are ready to enter the loop and compute the rest of the sequence. For each loop, we can use the following sequence of commands:

```
whisper> step
whisper> until 0x100b4
whisper> peek r t4
```

At the end of each cycle, you should see the following Fibonacci number printed in the `t4` register. Continue the simulation until the end or use `until 0x100d4` to simulate until the `DONE` label. We intentionally add an infinite loop at the end where we jump into the same location and execute the same instruction repeatedly. Feel free to `step` as many times as you wish.

Now our computation is done. Remember that our program also writes the computed Fibonacci numbers into an array on the memory. Check all the Fibonacci numbers from the memory using their address values:

```
whisper> peek m 0x110d8
0x000110d8: 0x00000000
whisper> peek m 0x110dc
0x000110e0: 0x00000001
whisper> peek m 0x110e0
0x000110e4: 0x00000001
whisper> peek m 0x110e4
0x000110e4: 0x00000002
...
whisper> peek m 0x11104
0x00011104: 0x00000059
```

The last Fibonacci number we have computed resides at the location `0x11104` and has a value of `0x59`, which `89` in decimal as expected.

Besides, we can look at a range of memory using the syntax below:

```
whisper> peek m 0x110d8 0x11104
```

This will print all Fibonacci number computed by our program. Type `quit` to end the simulation and interactive mode.

