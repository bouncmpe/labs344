# Simulate your first RISC-V program

This tutorial shows how to simulate a RISC-V assembly program using our development environment and tools. For this purpose, please find the assembly program `fibonacci.s` written in the RISC-V assembly language in this directory. We will simulate this and compute the first twelve elements of the Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89. 

## Assemble and Link

Once we have some program written in the RISC-V assembly language, we can produce an executable using the RISC-V toolchain, which contains RISC-V versions of the GNU programs `gcc`, `as`, `ld`. The prefix `riscv32-unknown-elf-` denotes that these compiler tools produce executables for RISC-V processors, not for our `x86-64` or `arm64` processors. The usage of the toolchain remains similar though.

We start by the following command to create `fibonacci.elf` executable file from `fibonacci.s`:

```
riscv32-unknown-elf-gcc fibonacci.s -o fibonacci.elf -nostdlib
```

Notice the use of the flag `-nostdlib` for the compile command as we do not want to link any standard library for our program for the moment, which is linked by default. Linking with other libraries will add more symbols to our object files and executables, which will be considered noise for our current goals. But later you try the steps below without setting the flag `-nostdlib`  to see the difference. 

The `fibonacci.elf` file is a binary executable file in the ELF format and contains the RISC-V instructions that compute the sequence of Fibonacci numbers. Since a binary file is not easily readable by humans, let's disassemble it first to see its content in the next section.

## Disassemble the ELF

Disassembling the ELF file means we convert the binary file `fibonacci.elf` in a human-readable textual file. We can disassemble ELF objects and executable using the program `objdump` as follows:

```bash
riscv32-unknown-elf-objdump --disassemble fibonacci.elf > fibonacci.dis
```

Now check out the contents of `fibonacci.dis`, which is a plain text file, in your text editor. It should look like this:

```
fibonacci.elf:     file format elf32-littleriscv

Disassembly of section .text:

00010094 <_start>:
   10094:   00001297             auipc t0,0x1
   10098:   04428293             addi  t0,t0,68 # 110d8 <__DATA_BEGIN__>
   1009c:   00a00313             li t1,10
   100a0:   00000393             li t2,0
   100a4:   00100e13             li t3,1
   100a8:   0072a023             sw t2,0(t0)
   100ac:   00428293             addi  t0,t0,4
   100b0:   01c2a023             sw t3,0(t0)

000100b4 <LOOP>:
   100b4:   02030063             beqz  t1,100d4 <DONE>
   100b8:   007e0eb3             add   t4,t3,t2
   100bc:   00428293             addi  t0,t0,4
   100c0:   01d2a023             sw t4,0(t0)
   100c4:   000e0393             mv t2,t3
   100c8:   000e8e13             mv t3,t4
   100cc:   fff30313             addi  t1,t1,-1
   100d0:   fe5ff06f             j  100b4 <LOOP>

000100d4 <DONE>:
   100d4:   0000006f             j  100d4 <DONE>
```

This file `fibonacci.dis` is somewhat similar to our `fibonacci.s` file, but now we see that the assembler and linker have made a few critical changes, like the annotation of address values on the instructions and labels. Notice that the assembler has also performed variable substitutions and replaced pseudo-instructions such as `la` with actual RISC-V instructions. 

## Simulate using Whisper

Our desktop computers usually have processors with the `x86-64` architecture. Therefore, we cannot natively execute programs like `fibonacci.elf` on our computers. We use RISC-V ISA simulators like `whisper` to simulate a RISC-V processor on our desktop computers and execute RISC-V executables. The `whisper` simulator is a production-grade simulator installed in our lab environment. Please check the `whisper` application first using the command:

```
whisper --help
```
You should see the help text of the `whisper` simulator with various commands and flags. Then everything is fine.

We first use the simulator in the interactive mode, where we can instruct commands to the simulator. To start the simulation of `fibonacci.elf` in the interactive mode, please run the command in your terminal as follows:
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

You can find other commands for `whisper` as listed in their docs [here](https://github.com/chipsalliance/SweRV-ISS).

Now we are ready to simulate our Fibonacci program. Execute `step` command to advance the program by one instruction. You will see the executed instruction printed in your terminal.

```
whisper> step
#1 0 00010094 00001297 r 05         00011094  auipc    x5, 0x1

whisper> step 
#2 0 00010098 04428293 r 05         000110d8  addi     x5, x5, 68

```

Besides advancing the simulation one by one, we can also use `step N` command to advance it by `N` steps. Moreover, we can simulate the program until reaching a particular instruction using `until <ADDR>` command. The `ADDR` is the address of the desired instruction. Let's simulate until the end of the initialization phase of our `fibonacci.elf` program by typing `until 0x100b4` where `0x100b4` is the address of `LOOP`:

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

