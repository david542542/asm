SYS_EXIT    = 60
SYS_WRITE   = 1
SYS_STDOUT  = 1

.section .rodata
number: .long   774

.text
.globl _start
_start:

    
    # set up stack, align on 16 for syscalls
    push %rbp
    mov %rsp, %rbp
    push number
    sub $16, %rsp

    # r12 will store the size of the string to print
    xor %r12d, %r12d

    # on the stack we will store:
    # rbp-16 (properly sorted number to print)
    # rbp-8  (number that remains)
    # rbp-4  (current right-most digit, ie,remainder)

  loop:

    # if the number is zero, jump to print it
    cmpl $0, -8(%rbp)
    je print
    inc %r12d # increment the size of the string to print

    # Divide by ten
    # - %rdx will give us the remainder (right-most digit)
    # - %rax will give us the new number (for our next iteration of the loop
    xor %edx,       %edx
    movl -8(%rbp),  %eax
    mov $10,        %ebx
    div %ebx

    movl %eax,  -8(%rbp)

    # (a) add 48, because ASCII is number + 48, for example ord('7') ==> 55
    addl $48,   %edx
    # (b) move the asci number to rbp-8-len (to print in reverse)
    # store offset (8+len) in %r13
    mov $-8,        %r13
    sub %r12,       %r13
    movb %dl,       (%rbp, %r13)

    jmp loop

    
  print:
    # print(%edi:stdout(int), %esi:mem_of_string(* void), %edx:len_of_string(int))
    # (b) How to print the digit to asci (probably fixed offset for 0-9)
    # Our output has length %r12 and starts at rbp-8-len
    # Which, conveniently enough, is (%rbp, %r13)!
    mov $SYS_STDOUT,    %edi
    lea (%rbp, %r13),   %rsi    # remember, this is an 8-byte MEMORY ADDRESS (pointer), not a number
    mov %r12d,          %edx
    mov $SYS_WRITE,     %eax
    syscall
    
  exit:
    add $8, %rsp    # <-- can also do an empty pop, such as pop %rcx
    mov             %rbp, %rsp
    pop             %rbp
    mov $0,         %rdi
    mov $SYS_EXIT,  %eax
    syscall
