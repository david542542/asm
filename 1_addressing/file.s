# Practicing the various Data Accessing methods

# Define a variable for later usage with addressing
.section .data
my_var:     .byte 4
my_array:   .word 20,25,30,35

# Note: by default, using $ ld uses the default `_start` as the entry point
# C-runtimes expect main, because they have their own _start
.section .text
.globl _start
_start:


    # (1) Immediate mode
    mov $9,     %rbx    # Move the literal value 9 into %rbx;               p/d $rbx
    mov $0x16,  %rbx    # Move the literal value 22 (16 in hex) into %rbx   p/x $rbx
    mov $0b11,  %rbx    # Move the literal value 3 (11 in binary) into %rbx p/t $rbx (t is 'two')
    

    # (2) Register addressing mode
    mov %rbx,   %rax   # Copy the value from %rbx into %rax


    # (3) Base pointer addressing mode
    mov %rsp,   %rbp        # Normall we would also first do push %rbp, but not required here
    movq $22,   -8(%rbp)    # Move the value 22 into the memory address at rbp-8
    movq -8(%rbp), %rcx     # Move the value at memory address rbp-8 (22) into rdx


    ## (4) Indirect addressing mode
    leaq -8(%rbp),  %rdx    # Move the address at rbp-8 into rdx
    movq (%rdx),    %r8     # Move the value of that memory address into r8
    movq %rdx,      %r9     # By comparison, see the value in r9 when using direct addressing mode


    # (5) Referencing a symbol
    mov my_var,  %r10     # move the value of the symbol `my_var` (4) into %r10
    mov my_var(%rip),%r11 # same as above, but more efficient and the preferred way to do it
    mov $my_var, %r12     # move the address of the symbol `my_var` into r12 (same as leaq my_var, %r12)


    # (6) Indexed addressing mode (used to access array elements)
    # Format is: offset(base_register, index_register, scale)
    # Additionally, here is a very helpful answer for `movz`: https://stackoverflow.com/a/31115069/12283181

    # (6a) Use a fixed offset and increment, note that base_register is empty
    movq $0, %rdi                       # we will use the %rdi register for our offsetting
    movzw my_array(,%rdi,2),    %r13    # the same as my_array[0], the '2' is the byte-size and fixed
    inc %rdi                            
    movzw my_array(,%rdi,2),    %r14    # same as above, but since we've incremented rdi, it's my_array[1]
    
    # (6b) We can also manually push our offsets, or use %rip-relative
    movzw my_array+6(,%rdi,2),  %r14    # we move two bytes starting at offset 6, my_array[3], and zfill to %r14
    movzw my_array(%rip),       %r15    # Another way to access an array
    movzw my_array+4(%rip),     %r13    # With the offset before %rip


    # Finally, we will exit the program
    mov $1, %rax    # rax holds the Linux syscall: #1 is the exit() syscall
    mov $24, %rbx   # rbx is the register that holds the return  value
    int $0x80





