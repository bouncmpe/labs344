#include "defines.h"

.global _start
_start:

// Clear minstret (Instruction Retired Register)
csrw minstret, zero
csrw minstreth, zero

// Enable Caches in MRAC
li x1, 0x5f555555
csrw 0x7c0, x1

# Register t3 is also called register 28 (x28)
li t3, 0x0					# t3 = 0

REPEAT:
	addi t3, t3, 6			# t3 = t3 + 6
	addi t3, t3, -1		    # t3 = t3 - 1
	andi t3, t3, 3			# t3 = t3 AND 3
	beq  zero, zero, REPEAT	# Repeat the loop

.end