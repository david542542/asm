.section .data

.section .text
.globl _start
_start:
    mov $1, %eax
    mov $2, %ebx
    int $0x80
    
