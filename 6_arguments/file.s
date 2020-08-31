.globl _start

_start:
    
    # Calculate 2*3 + 7*9 = 6 + 63 = 69
    # The multiplication will be done with a separate function call

    # Parameters passed in System V ABI
    # The first 6 integer/pointer arguments are passed in:
    #   %rdi, %rsi, %rdx, %rcx, %r8, and %r9
    # The return value is passed in %rax

    # multiply(2, 3)
    # Part 1 --> Call the parameters
    mov $2, %rdi
    mov $3, %rsi
    # Part 2 --> Call the function (`push` return address onto stack and `jmp` to function label)
    call multiply
    # Part 3 --> Handle the return value from %rax (here we'll just push it to the stack as a test)
    push %rax

    # multiply(7, 9)
    mov $7, %rdi
    mov $9, %rsi
    call multiply
    
    # Add the two together
    # Restore from stack onto rdi for the first function
    pop %rdi
    # The previous variou from multiply(7,9) is already in rax, so just add to rbx
    add %rax, %rdi

    # for the 64-bit calling convention, do syscall instead of int 0x80
    # use %rdi instead of %rbx for the exit arg
    # use $60 for th exit code

    movq $60, %rax    # use the `_exit` [fast] syscall
                      # rdi contains out exit code
    syscall           # make syscall


multiply:
    mov %rdi, %rax
    imul %rsi, %rax
    ret
