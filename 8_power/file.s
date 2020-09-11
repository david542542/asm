# We are going to calculate 7^2 + 2^4 = 49 + 16 = 65
# The exponent function supports whole numbers (long) >= 0

.section .data
base_1: .long   7
exp_1:  .long   2
base_2: .long   2
exp_2:  .long   4

.section .text
.globl _start
_start:


    # We will do the first function call, 7^2
    mov base_1(%rip),   %edi
    mov exp_1(%rip),    %esi
    call exp

    # needs to be 16-byte aligned before the next function call so do two pushes
    pushq $0
    pushq %rax

    # Now do the second function call
    mov base_2(%rip),   %edi
    mov exp_2(%rip),    %esi
    call exp

    # We have the return value in %eax so let's add this with our previous function's value
    popq %rdi
    
    add %eax,   %edi
    mov $60,    %eax
    syscall

exp:
    # Initialize %eax to 1
    mov $1,     %eax

exp_op:
    cmp $0,     %esi
    je exp_ret
    imul %edi,  %eax
    dec %esi
    jmp exp_op

exp_ret:
    ret


