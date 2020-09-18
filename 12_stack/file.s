# Program, print out a list of strings, one per line, with its line number
# For example, if the input is: ['hello', 'new', 'world'], the output will be:
# 1 - hello
# 2 - new
# 3 - world
.data

SYS_EXIT   = 60
SYS_WRITE  = 1
SYS_STDIN  = 0
SYS_STDOUT = 1
SYS_STDERR = 2

# Empty string means end of strings
strings:    .asciz  "Once\n", "upon\n", "a\n", "time\n", "...\n", ""

.text
.globl _start

get_string_length:  # (edi=starting_memory_address)
    # we will store the string size in %rax
    mov $0, %eax
  .L1_loop:
    # move a single character into %ecx (easier to debug, rather than a direct compare)
    # movb (%edi, %eax), %bl <-- won't work because the high bits might be non-zero
    movzbl (%edi, %eax), %ecx
    # check if that byte is the nul character
    cmp $0, %cl
    je .L1_exit
    inc %eax
    jmp .L1_loop
  .L1_exit:
    ret

# rdi rsi rdx r10 r8  r9

# concat_strings: # (edi=string1, esi=stringlen1, edx=string2, r10d=stringlen2, r8d=write_address)
                # also need to convert number to asci !

    

_start:

    # The procedure will be:
    # for each string:
    #   (1) get the size
    #   (2) if size == 0: exit
    #   (3) concat that string with the line number <-- this is tough. Next task
    #   (4) print the memory_address + size offset
    #   (5) advance to size offset + 1 (nul) byte

    # Function(%rdi, %rsi, %rdx) ==> %rax
    # Because rdi is not call-preserved, we will store the starting memory address of
    # the array of strings in %rbx -- that is, the starting memory address of the current string
    mov $strings,   %rbx
    mov $1,         %r12d
    
  print_loop:
    mov %rbx,       %rdi
    call get_string_length # (rdi=file_descriptor, rsi=starting_address, rdx=size)
    cmp $0, %eax
    jz exit
    mov $SYS_STDOUT,%edi
    mov %rbx,       %rsi
    mov %eax,       %edx
    mov $SYS_WRITE, %eax
    syscall

    lea 1(%eax, %ebx,), %ebx
    # add %eax,       %ebx
    # inc %ebx
    jmp print_loop

  exit:
    mov $0,        %edi
    mov $SYS_EXIT, %eax
    syscall


    # need our string length
    # mov $string, %rdi
    # # call get_string_length
    # mov %eax,   %edx

    # # function_call (%rdi, %rsi, %rdx, %r10, %r8, %r9)
    # # Do a syswrite call -- https://en.wikipedia.org/wiki/Write_(system_call)
    # # write(file_description (0=stdin, 1=stdout, 3=stderr), start_of_buf, num_bytes)
    # # mov $SYS_STDOUT,    %rdi
    # # mov $string,        %rsi
    # # mov $string_len,    %rdx      # can use assemble-time len instead of run-time
    # # mov $SYS_WRITE,     %eax
    # # syscall
    
    # # mov $1,     %rax    # move decimal
    # # mov $0xA,   %rbx    # move hex
    # # mov $0b100, %rcx    # move binary
    # # mov $'b',   %rdx    # move asci char (only one char works)

    # pop %rbp
    # mov %rsp, %rbp
    # sub $8, %rsp
    # # mov $string, %rax
    # # mov %eax

    # # # movabsq moves a 64-bit immediate into a 64-bit register
    # # movabsq $0x467265646479, %rax    # 'Freddy' in hex
    # # movq %rax, -4(%rbp)
    # # movabsq $0x4461766964, %rax
    # # shl $8*3, %rax
    # # movq %rax, -8(%rbp)
    # # movl $0x44617669, -8(%rbp)
    # # movl $0x64, -4(%rbp)

    # mov $SYS_STDOUT,    %edi
    # lea symbols,        %rsi
    # mov $symbols_len,   %edx
    # mov $SYS_WRITE,     %eax
    # syscall

    # mov $0,             %edi
    # mov $SYS_EXIT,      %eax
    # syscall



/* Important notes!!!
string:     .asciz "hello world!\n" */
# string_len: . - string
# can look up the utf-8 hex codes for it on http://www.fileformat.info/info/charset/UTF-8/list.htm
# or use xxd and type in the symbol.
# symbols:    .byte 0x24, 0xc2, 0xa5, 0xc2, 0xa3
# symbols_len= . - symbols
# symbols:    .byte   0x24 0xc2

# ... haven't even gotten to one! was trying to write a string to the stack and print from there...
# 1 - open and read a file
# 2 - open and write a file
