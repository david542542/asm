# Linux system calls listed here: https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86-32_bit
# file.o is an object file that is created by the assembler (as), which is in the machines language but not completely but together. 
# The linker (ld) is responsible for putting the object files together so the kernel can run it.


# (1) To disassemble the parts containing code in the executable, we can do:
#    $ objdump --disassemble --section=.text file

#    file:     file format elf64-x86-64

#    Disassembly of section .text:

#    0000000000400078 <_start>:
     # 400078:	b8 01 00 00 00       	mov    $0x1,%eax
     # 40007d:	8b 1d 02 00 00 00    	mov    0x2(%rip),%ebx        # 400085 <a>
     # 400083:	cd 80                	int    $0x80


# (2) To examine hard-coded string data, we can do:
# $ readelf --hex-dump .rodata file

# Hex dump of section '.rodata':
    # 0x00400085 11646176 696400                     .david.

# Anything starting with a period isn't directly translated into a machine instruction.
# Instead it's an instruction to the assembler itself. These are called assembler directives.
.section .rodata
    a: .byte 17         # 1 byte
    s: .string "david"  # 1 byte per character
    data_items: .word 2,9,38,1,3,92,7,0     # use zero as the sentinel value

# Examples with examining and printing:

# >>> info va
# Non-debugging symbols:
# 0x000000000040009d  a
# 0x000000000040009e  s
# 0x00000000004000a4  data_items
# >>> x/bd &a
# 0x40009d:   17
# >>> x/s &s
# 0x40009e:   "david"
# >>> x/8h &data_items
# 0x4000a4:   2   9   38  1   3   92  7   0


# The .text section is where our program instructions live.
.section .text

# _start is a `symbol`, which are used to mark memory locations in our programs or data,
# so that we can refer to them by name instead of by their memory location
# symbols are used so that the assembler and linker can take care of keeping track of memory addresses
.globl _start

# A label is a symbol followed by a colon. When the assembler if assembling the program, it has to assign
# each data value and instruction an address, 
_start:

    # COMPARISONS & FLAGS: second operand must be a register
    # Note: this is a bit tricky with ATT syntax: doing `cmp a, b` does the operation as b-a,
    #       which can affect the parity flag

    # IF ==> Interrupt Flag (basically handled by the Operating system, always on)
    # ZF ==> Zero flag      (comparison is the same)
    # SF ==> Sign flag      (1 if b > a)
    # PF ==> Parity flag    (number of bits of the LSB that are set, cmp a,b does b-a, 0b01 --> odd (0), 0b11 --> even (1)
    # CF ==> Carry flag     (carry required on MSB)
    # AF ==> Adjust flag    (carry required on LSB)

    #   https://en.wikipedia.org/wiki/FLAGS_register
	#   15	14	13	12	11	10	9	8	7	6	5	4	3	2	1	0	(bit position)
	#   -	-	-	-	O	D	I	T	S	Z	-	A	-	P	-	C	Flags

    # skip over the parity stuff, we just keep it here for documentation
    jmp start_loop

    # PARITY FLAG (PF)
    # a < b -- parity flag will be set to 1, since b-a = 0b11 (even number of bits set to 1)
    mov $4, %rax
    mov $7, %rbx
    cmp %rax, %rbx  # [ PF IF ]

    # a < b -- parity flag will be set to 0, since b-a = 0b01 (odd number of bits set to 1)
    mov $4, %rax
    mov $5, %rbx
    cmp %rax, %rbx  # [ IF ]

    # ZERO FLAG (ZF)
    # a = b -- 0b00
    mov $5, %rax
    mov $5, %rbx
    cmp %rax, %rbx  # [ PF ZF IF ]

    # SIGN FLAG (SF) -- just means second operand is bigger than first
    # a > b, -- 0b01
    mov $2, %rax
    mov $0, %rbx
    cmp %rax, %rbx  # [ CF AF SF IF ]

    # Carry flag (CF) -- Borrow on MSB
    mov $0b110000, %rax
    mov $0b010000, %rbx
    cmp %rax, %rbx  # [ CF SF IF ]

    # Adjust/Auxiliary flag (AF) -- Borrow on LSB
    mov $0b110, %rax
    mov $0b100, %rbx
    cmp %rax, %rbx  # [ CF AF SF IF ]

    
    # MAXIMUM program: find the max value in an array
    # Examine data_items to get the maximum item
    # `data_items` is used to store the array of numbers, '0' is used to signal the end
    # %rdi is used to store the index
    # %rax is used to store the current item
    # %rbx is used to store the current maximum (and this works nice since %rbx is the return value on `exit`)

    # Let's zero out the %rdi register so we're at array index 0
    # Note: moving an immediate value always sizes to the register (i.e., equivalent of movzbq)
    mov $12345332, %rdi
    mov $0, %rdi

    # # Let's also zero out the current maximum
    mov $0, %rbx
    

start_loop:

    # Get the current element in the array and move it to %rax
    # movz --> (1) b(yte-1), w(ord-2), l(long-4), q(uad-8)
    movzwq data_items(,%rdi,2), %rax
    
    # Check if the current element value is zero, if it is, jump to the end
    cmp $0, %rax
    jz exit

    # Increment the array index as we want to continue the loop at the end
    inc %rdi

    # Compare the current value (rax) to the current max (rbx)
    # WARNING: The `cmp` instruction is always backwards with ATT syntax!
    # It reads as, "With respect to %rbx, the value of %rax is...(greater|less) than"
    # So to see if a > b, do:
    #   cmp b, a
    #   jg
    # Reference: https://stackoverflow.com/a/26191257/12283168
    cmp %rbx, %rax
    jge update_value


    jmp start_loop


update_value:
    mov %rax, %rbx
    jmp start_loop


exit:
    # Note: arg0 is stored in %rbx, int error_code. Returns error_code & 0xFF (16 bits)
    # We are already storing the max value in %rbx so we don't need to set it here

    # `1` is the linux kernel command number (system call) for exiting a program
    # and `int` make a syscall to the linux kernal by calling interrupt 0x80
    mov $1, %rax            
    int $0x80               
    
