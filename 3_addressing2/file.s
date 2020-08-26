# More general form of memory addressing
# Links: http://www.sig9.com/articles/att-syntax
#        http://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html#:~:text=Modern%20x86%2Dcompatible%20processors%20are,that%20specify%20addresses%20in%20memory.

# VARIABLES/LABELS
.section .rodata
my_array: .word 1,3,9,27
my_var:   .word 927

# To print the array in `gdb`, we can do: 
#   >>> x/4hd &myarray
#   0x400078 <myarray>: 1   3   9   27

# To see all the symbols in an object file we can do:
#   $ nm file.o to see all the symbols in an object file
#    0000000000000000 T _start
#    0000000000000000 r myarray
#    0000000000000008 r myvar

# Additionally, if we put the variables in a `.data` or `.rodata` section, gdb will show variables:
#   >>> info va(riables)
#   Non-debugging symbols:
#   0x00000000004000c7  myarray
#   0x00000000004000cf  myvar
#   0x00000000006000d1  __bss_start
#   0x00000000006000d1  _edata
#   0x00000000006000d8  _end

# Also notice how both variables are contiguous in memory (and the same size so good for printing!)
#   >>> x/5hd &myarray
#   0x4000c7:   1   3   9   27  927

.section .text
.globl _start
_start:

    mov %rsp, %rbp

    # There are three main ways to address memory.
    # (1) Using a LITERAL/IMMEDIATE value
    mov $9, %rax

    # (2) Using a REGISTER
    mov %rax, %rbx

    # (3) Using a MEMORY address. 
    # The rest of this will discuss using this format, as its the most complex
    # FORMAT: Address_Or_Offset(%Base_Or_Offset, %Index, Scale)
    #         And the actual vaue is retrieved from the address at: Address + Base + Index*Scale
    #         Scale is either 1,2,4,8 (basically, the size of the array element)
    #         %Index is basically like the arrayIndex, so we can do something like MyArray[1]
    #         Address/%Base are almost interchangeable, though one must be a register and the other is not.

    # To add in the first array element just reference the address
    # Notice that in this case Address_Or_Offset is, of course, Address
    movzwq my_array, %rcx

    # We can also use an offset to get that element, specifying the element size of 2
    mov $1, %rdi
    movzwq my_array(, %rdi, 2), %rdx  # equivalent of my_array[rdi] or my_array[1]

    # Let's move the memory address of the label into a register and use *that* instead
    lea my_array, %r8
    movzwq (%r8), %r9            # my_array[0]
    movzwq (%r8, %rdi, 2), %r10  # same as above -- my_array[rdi] or my_array[2]


    # (4) OTHER 
    # (4a) `movz` command
    # # movz --> (1) b(yte-1), w(ord-2), l(long-4), q(uad-8)
    # # Options include: movzbw, movzbl, movzbq, movzwl, movzwq
    # # Note, for adding a literal, using movz is not necessary as it automatically zero-extends if necessary
    movq $0x1111111111111111, %rax
    mov $4, %rax   # notice how even though we added a long, the upper 32-bits are empty


    # (5b) Manually adding an array into memory
    # Manually move the `short` array [1, 3, 9, 27] into memory
    # Note that we store the first element of the array at the lowest memory address
    # This makes sense, as the **Start** of the array is at the lowest memory location and grows upwards
    movw $1, -8(%rbp)
    movw $3, -6(%rbp)
    movw $9, -4(%rbp)
    movw $27,-2(%rbp)
    #   >>> x/4hd $rbp-8
    #   0x7fffffffe438: 1   3   9   27

    # An example of using offsets in memory addressing to store and access values
    # of the manually-created array
    lea -2(%rbp), %r10  # this corresponds to my_array[2] in the stack, relative to %rbp
    # >>> x/hd $r10
    # 0x7fffffffe43e: 27

    
    # (5c) %rip-relative addressing: the below will all resolve to the same `myvar` address at runtime
    mov my_var, %rax
    mov my_var(%rip), %rax
    mov my_var(%rip), %rax
    # 0x00000000004000b0  ? mov    0x600107,%rax
    # 0x00000000004000b8  ? mov    0x200048(%rip),%rax        # 0x600107
    # 0x00000000004000bf  ? mov    0x200041(%rip),%rax        # 0x600107

    mov $1, %eax
    int $0x80

