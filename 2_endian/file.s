# Storing and reading bytes in Little Endian

# `ld` assumes that the program starts at the first byte if no (global) symbol named `_start` is found.
# More information from this answer: https://stackoverflow.com/a/63551733/12283168
# More info on `ld`: https://linux.die.net/man/1/ld
.globl _start
_start:

    # Store a few values in different formats
    mov     %rsp,       %rbp
    movb    $0xA,      -1(%rbp)
    movb    $3,         -2(%rbp) # Note: not possible to do something like $0d3 in GAS
    movw    $0b100,     -4(%rbp)

    # Move the word 'John' to memory
    # x86 is little-endian (LE)
    # 'J' is the most significant bit in 'John' and because it is LE, it will
    # Occurs at the lowest address in memory. Because we are using negative indexing
    # relative to %rbp, the 'J' will be at the MOST_NEGATIVE offset. For example:
    #   >>> x/c $rbp-
    #   0x7fffffffe438: 74 'J'
    #   >>> x/c $rbp-7
    #   0x7fffffffe439: 111 'o' <-- notice the higher address in memory! 439 vs 438
    movb    $'J',        -8(%rbp)   # 4A
    movb    $'o',        -7(%rbp)   # 6F
    movb    $'h',        -6(%rbp)   # 68
    movb    $'n',        -5(%rbp)   # 6E


    # Now let's try moving two two-byte numbers into memory
    movw    $300,       -10(%rbp)   # 12C
    movw    $4600,      -12(%rbp)   # 11F8
    movw    $2,         -14(%rbp)   # 2
    movw    $22,        -16(%rbp)   # 16

    # After all the above is done, we will have the following in memory
    # Note that the memory addresses go down as the table goes down (like the stack)

    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | %rbp offset | address | byte type | size | value | debug | examine                 |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -1          | 43F     | --        | byte | 0xA   | 10    | x/1bx $rbp-1            |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -2          | 43E     | --        | byte | 0x3   | 3     |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -3          | 43D     | MSB       |      | 0x00  |       |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -4          | 43C     | LSB       | word | 0x04  | 4     | x/1hx $rbp-4            |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -5          | 43B     | -- (MSB)  | byte |       | n     |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -6          | 43A     | --        | byte | 68    | h     |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -7          | 439     | --        | byte | 6F    | o     |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -8          | 438     | -- (LSB)  | byte | 4A    | J     | x/4c $rbp-8, x/s $rbp-8 |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -9          | 437     | MSB       |      | 0x01  |       |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -10         | 436     | LSB       | word | 0x2C  | 300   | x/hd $rbp-10            |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -11         | 435     | MSB       |      | 0x11  |       |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -12         | 434     | LSB       | word | 0xF8  | 4600  |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -13         | 433     | MSB       |      | 0x00  |       |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -14         | 432     | LSB       | word | 0x02  | 2     |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -15         | 431     | MSB       |      | 0x00  |       |                         |
    +-------------+---------+-----------+------+-------+-------+-------------------------+
    | -16         | 430     | LSB       | word | 0x16  | 22    | x/4hx $rbp-16,          |
    +-------------+---------+-----------+------+-------+-------+-------------------------+

    mov $1, %eax
    int $0x80
