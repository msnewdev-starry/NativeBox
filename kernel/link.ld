/* Kernel linker script for PE format
   Links bootloader and kernel with PE format support */

ENTRY(kernel_main)

SECTIONS
{
  /* Start at 0x10000 */
  . = 0x10000;
  
  .text :
  {
    *(.text)
    *(.text.*)
  }
  
  .rodata :
  {
    *(.rodata)
    *(.rodata.*)
  }
  
  .data :
  {
    *(.data)
    *(.data.*)
  }
  
  .bss :
  {
    *(.bss)
    *(COMMON)
  }
}
