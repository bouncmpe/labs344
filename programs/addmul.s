#include "defines.h"

.globl _start
_start:

# Enable Caches in MRAC
li x1, 0x5f555555
csrw 0x7c0, x1

# Disable Pipeling
# Setting the first bit of the 0x7F9 register to 1 disables the pipeline
# https://github.com/chipsalliance/Cores-VeeR-EL2/blob/main/docs/source/core-control.md
# li t2, 0x001
# csrrs t1, 0x7F9, t2

# Disable Advanced Branch Predictor
# Setting the third bit of the 0x7F9 register to 1 disables the branch predictor
# https://github.com/chipsalliance/Cores-VeeR-EL2/blob/main/docs/source/core-control.md
# li t2, 0x008
# csrrs t1, 0x7F9, t2

li x28, 0x1
li x29, 0x2
li x30, 0x4
li x31, 0x1
 
REPEAT:
   nop;
   nop;
   mul x28, x29, x29
   add x30, x30, x31
   nop; 
   nop; 
   nop; 
   nop;
   add x29, x29, 1
   nop; 
   nop; 
   nop; 
   nop;
   beq  zero, zero, REPEAT # Repeat the loop
