.section .data
a: .long 3
b: .long 4
c: .float 3.14
d: .single 5.99 # single and float are the same.

# To print a variable
# >>> x/d &a
# 0x6000d7:   3

# >>> x/f &c
# 0x6000df:   3.1400001

.section .text
.globl _start
_start:
    
    # Let's add two numbers together
    # Function Parameters: %rdi, %rsi, %rdx, %rcx, %r8, and %r9 | Return: %rax
    # add_ints(a, b)
    mov a(%rip), %edi
    mov b(%rip), %esi
    call add_ints

    # Now let's try doing the same thing but with a decimal (float)
    # xmm0 xmm1 xmm2 xmm3 xmm4 xmm5 xmm6 xmm7
    movss c(%rip), %xmm0 
    movss d(%rip), %xmm1 
    call add_floats

    # To print the float registers
    # >>> p $xmm0.v4_float[0]
    # $4 = 3.1400001
    # >>> p $xmm0.v2_double[0]
    # $5 = 5.3286132608536752e-315

    # For now, let's just return the add_ints result as the exit code
    mov %eax, %edi
    mov $60, %eax
    syscall

add_ints:
    # lea trick for adding, look at how simple this is
    # the memory address will load (offset + %base + %index * multiplier), and to add two numbers we can 
    # put one number in the `base` register and another in `index` and so it will add those together:
    # (0 + %base + %index * 1) = base (%edi) + index (%esi) = %edi (a) + %edii (b) = a + b
    # The `mov` would load the value at memory address 7, whereas `lea` just copies over that number as-is
    # And, if we wanted to add in a constant, we could always use the offset for that, for example:
    # To add a + b + 7, we could do:
    # 7(%edi, %esi)
    lea (%edi, %esi), %eax
    # mov %edi, %eax
    # add %esi, %eax
    ret
    

add_floats:
    # floats to be passed back in xmm0 register
    addss %xmm1, %xmm0
    ret
