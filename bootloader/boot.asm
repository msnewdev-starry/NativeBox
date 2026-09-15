; NativeBox Bootloader
; x86 16-bit real mode bootloader
; Loads kernel and switches to protected mode

BITS 16
ORG 0x7C00

; Boot sector header
boot_start:
    jmp short main
    nop

; BIOS Parameter Block (for compatibility)
bpb:
    db 0x00, 0x00, 0x00        ; Filler
    db 0x00, 0x00, 0x00, 0x00  ; OEM identifier
    dw 512                      ; Bytes per sector
    db 1                        ; Sectors per cluster
    dw 1                        ; Reserved sectors
    db 2                        ; Number of FATs
    dw 224                      ; Root directory entries
    dw 2880                     ; Total sectors
    db 0xF0                     ; Media descriptor
    dw 9                        ; Sectors per FAT
    dw 18                       ; Sectors per track
    dw 2                        ; Number of heads
    dd 0                        ; Hidden sectors
    dd 0                        ; Large total sectors

main:
    cli                         ; Clear interrupts
    
    ; Initialize segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    sti                         ; Set interrupts
    
    ; Print boot message
    mov si, boot_msg
    call print_string
    
    ; Enable A20 line
    call enable_a20
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Switch to protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    ; Far jump to protected mode
    jmp 0x08:protected_mode

; Print string subroutine
; Input: DS:SI = pointer to string
print_string:
    pusha
.print_loop:
    lodsb                       ; Load byte from string
    cmp al, 0
    je .print_done
    
    mov ah, 0x0E                ; BIOS teletype mode
    int 0x10
    jmp .print_loop
    
.print_done:
    popa
    ret

; Enable A20 line for >1MB memory access
enable_a20:
    push ax
    
    ; Try using BIOS
    mov ax, 0x2401
    int 0x15
    
    pop ax
    ret

; Global Descriptor Table
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0
    
    ; Code segment
    dw 0xFFFF                   ; Limit (bits 0-15)
    dw 0x0000                   ; Base (bits 0-15)
    db 0x00                     ; Base (bits 16-23)
    db 0x9A                     ; Access byte
    db 0xCF                     ; Granularity
    db 0x00                     ; Base (bits 24-31)
    
    ; Data segment
    dw 0xFFFF                   ; Limit (bits 0-15)
    dw 0x0000                   ; Base (bits 0-15)
    db 0x00                     ; Base (bits 16-23)
    db 0x92                     ; Access byte
    db 0xCF                     ; Granularity
    db 0x00                     ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Protected mode
BITS 32
protected_mode:
    mov ax, 0x10                ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, 0x90000            ; Stack pointer
    
    ; Jump to kernel
    jmp 0x10000

boot_msg db "NativeBox Bootloader v1.0", 0x0D, 0x0A, "Loading kernel...", 0x0D, 0x0A, 0

; Padding and boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
