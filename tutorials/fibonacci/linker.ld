ENTRY(_start)

MEMORY
{
  ROM (rx)  : ORIGIN = 0x80000000, LENGTH = 64K
  RAM (rwx) : ORIGIN = 0x80010000, LENGTH = 64K
}

SECTIONS
{
    .text : ALIGN (4) {
        _text_start = .;
        *(.init)
        *(.text)
        *(.text.*)
        _text_end = .;
    } > ROM

    .rodata : ALIGN (4) {
        _rodata_start = .;
        *(.rodata)
        *(.rodata.*)
        _rodata_end = .;
    } > ROM

    .data : ALIGN (4) {
        _data_start = .;
        *(.data)
        *(.data.*)
        _data_end = .;
    } > RAM

    .bss (NOLOAD): ALIGN (4) {
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(8); 
        tohost   = .;
        . += 8;
        fromhost = .;
        . += 8;
        _bss_end = .;
    } > RAM

    . = ORIGIN(RAM) + LENGTH(RAM);
    PROVIDE(_stack_top = .);
    . = . - 16K;
    PROVIDE(_stack_bottom = .);
    
    .stack (NOLOAD) : ALIGN (16) {
    } > RAM
}
