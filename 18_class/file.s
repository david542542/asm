# Implement a basic 'class' in assembly for a bitArray 
.globl _start

bit_array_init:
    # all this has to do is clear N bits (%rdi) starting at address (%rsi); return void
    mov $-1, %rax   # mask of all 1's
    mov %dil, %cl
    shl %cl, %rax       # shift left by the number of bits, filling right-side with 0's
    andq %rax, (%rsi)   # because the mask is all 1's above the bit count, it doesn't matter
    ret                 # if we 'extend too far' since &1 will have no affect

bit_array_set:
    # index (%rdi), address (%rsi); return void
    # can do num | 1 << pos, or use btw instruction - https://www.felixcloutier.com/x86/bts
    bts %rdi, (%rsi)
    ret

bit_array_unset:
    # index (%rdi), address (%rsi); return void
    # can do num & 0 << pos, or use btr instruction - https://www.felixcloutier.com/x86/btr
    # NOTE: BTS is Set, BTR is Reset, and BTC is Complement/invert
    btr %rdi, (%rsi)
    ret

bit_array_get:
    # index (%rdi), address (%rsi); return 1/0 in AL register (note, we're not clearing rax)
    # can do num & 1 << pos, or use bt instruction - https://www.felixcloutier.com/x86/bt
    bt %rdi, (%rsi)
    setc %al
    ret

bit_array_print:
    # use the stack as our temporary buffer to print the chars
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    mov $1,  %rcx    # bitmask to test
    mov $-1, %rdx    # char index -- this is an offset relative to rbp for where the char goes
    mov %rdi, %r8    # copy the length to decrement into a temporary register

    # Note: it might be simpler to do pushb for each '0' or '1' char
    #       which might make it easier to deal with the stack and not have to negative index
  add_char:
    test %ecx,  (%rsi)
    jnz set_one
    movb $'0', (%rbp, %rdx)
    jmp end_set
   set_one:
    movb $'1', (%rbp, %rdx)
   end_set:
    dec %rdi
    jz print_chars
    shl %ecx
    dec %rdx
    jmp add_char

   print_chars:
    mov $1, %rax
    mov $1, %rdi
    lea (%rbp, %rdx), %rsi
    mov %r8, %rdx
    syscall

    add $8, %rsp
    mov %rbp, %rsp
    pop %rbp
    ret
    
_start:
    
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
    movl $0b110110110110110110, -4(%rbp) # dirty up the stack so can make sure things working
    
    # 1. Init the bitArray, b = BitArray(BIT_SIZE, address); allocated locally on the stack
    # Let's store the 'memory address' of the object in %rbx
    # This is kind of like b = BitArray(5), where b is the memory address stored in %rbx
    lea -4(%rbp),   %rbx
    mov $8,         %edi
    mov %rbx,       %rsi
    call bit_array_init

    # 2. Set the 0th and 4th bit, then Unset the 0th bit
    mov %rbx,   %rsi  # we won't modify rdi in these function so dont have to keep repeating
    mov $0,     %edi
    call bit_array_set
    mov $4,     %edi
    call bit_array_set
    mov $0,     %edi
    call bit_array_unset
    
    # 3. Check to see what the bit value is 1 or 0
    mov %rbx,   %rsi
    mov $4,     %rdi
    call bit_array_get
    mov $3,     %rdi
    call bit_array_get

    # 4. Print the bitarray as a string, print(size, address)
    mov $8,     %edi
    mov %rbx,   %rsi
    call bit_array_print

    # re-align things
    add $8, %rsp
    mov %rbp, %rsp
    pop %rbp

    mov $60, %eax
    mov $0, %rdi
    syscall
