BITS 64

GLOBAL _inicio  

EXTERN __executable_start
EXTERN _start

; Posible multiboot header flags
;
MULTIBOOT_MODULE_ALIGN     equ 1<<0
MULTIBOOT_MEMORY_MAP       equ 1<<1
MULTIBOOT_GRAPHICS_FIELDS  equ 1<<2
MULTIBOOT_ADDRESS_FIELDS   equ 1<<16

; Multiboot header defines
;
MULTIBOOT_HEADER_MAGIC     equ 0x1BADB002     
MULTIBOOT_HEADER_FLAGS     equ MULTIBOOT_MODULE_ALIGN | MULTIBOOT_MEMORY_MAP | MULTIBOOT_ADDRESS_FIELDS
MULTIBOOT_HEADER_CHECKSUM  equ -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

SECTION .text                   ; .text - multiboot header and _inicio
align 4
MULTIBOOT_HEADER_HEADER:
dd MULTIBOOT_HEADER_MAGIC
dd MULTIBOOT_HEADER_FLAGS
dd MULTIBOOT_HEADER_CHECKSUM
dd MULTIBOOT_HEADER_HEADER
dd __executable_start
dd 0
dd 0
dd _inicio

_inicio:                        ; set up stack, push header, continue
    mov rsp, KERNEL_STACK_END
    push rbx
    jmp  _start

SECTION .bss                    ; .bss - kernel stack
align 32
    resb 0x4000
KERNEL_STACK_END:
