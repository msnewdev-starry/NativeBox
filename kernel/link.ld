; Kernel entry point linker script
; Links bootloader, kernel and provides memory layout

ENTRY(kernel_main)

SECTIONS {
    . = 0x10000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
        *(COMMON)
    }
}
