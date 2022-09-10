.globl _start             # Make _start symbol visible outside

.equ N, 12                # Set N to 12. We want to compute first 12 Fibonacci numbers including initial 0 and 1 

.section .bss             # .bss is a read-write section containing global uninitialized data (abbreviated as .bss)
V: .space 4*N             # Reserve 4*N bytes on memory for our output array, V, having a length of N and 32-bit members
                          # Do not assume this array is always initialized to all zeros, though often it is.

# .section .data          # .data is a read-only section containing global static data (abbreviated as .data)
# Z: .word 0,1,1,2,3,5,8,13,21,34,55,89                      

.section .text            # .text is a read-only section containing executable code (abbreviated as .text)
_start:                   # _start symbol is special, the program starts here
  la t0, V                # Register `t0` keeps the address of the array index `i`, initially V[0]. 
  li t1, N-2              # Register `t1` keeps the loop index j, initially set to N-2
  li t2, 0                # Register `t2` keeps the Fibonacci number before the last one, initially set to 0
  li t3, 1                # Register `t3` keeps the last Fibonacci number, initially set to 1
  sw t2, (t0)             # Store the current value of `t2` into V[i] where i=0
  add t0, t0, 4           # Increment to the next address value (address values increase by 4)
  sw t3, (t0)             # Store the current value of `t2` into V[i] where i=1
                          # Now we have V[0]=0, V[1]=1

LOOP:
  beq t1, zero, DONE      # if(j == 0){ goto DONE;} 
  add t4, t3, t2          # t4 = t3 + t2
  add t0, t0, 4           # i++
  sw t4, (t0)             # V[i] = t4
  mv t2, t3               # t2 = t3;
  mv t3, t4               # t3 = t4;
  add t1, t1, -1          # j--
  j LOOP                  # Jump LOOP label unconditionally

DONE:                     # Dummy infinite loop -- we must exit here
  j . 
