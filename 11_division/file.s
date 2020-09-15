.section .data
nums: .long 8,9,1,7,22,98,-1

.section .text
.globl _start
_start:
    pop %rbp
    mov %rsp, %rbp

    # store the index at %r8
    movl $0, %r8d
    # move the value at that index to %edi
  loop:
    mov nums(,%r8d,4), %edi
    cmp $-1, %edi
    je exit
    # move the factor into %esi
    mov $2, %esi
    call is_divisible_by
    inc %r8d
    cmp $1, %eax
    jne loop
    mov %edi, %r10d
    jmp loop

    # first three args: %edi, %esi, %edx
  exit:
    mov %r10d, %edi
    mov $60, %eax
    syscall

is_divisible_by:
    push %rbp
    mov %rsp, %rbp
    # movl %edi, -4(%rbp)
    # movl %esi, -8(%rbp)

    mov $0, %edx
    mov %edi, %eax
    mov %esi, %ecx
    divl %ecx
    cmp $0, %rdx
    je set_true
  set_false:
    mov $0, %eax
    jmp clean_up
  set_true:
   mov $1, %eax
   jmp clean_up
  clean_up:
    mov %rbp, %rsp
    pop %rbp
    ret

