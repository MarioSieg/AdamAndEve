# Prints a single 8-bit ASCII character using BIOS interrupts.
# The char to print must be in %al
_PRINT_CHAR_16_:
    movb    $0xE, %ah   # Set to teletype
    int     $0x10       # Call BIOS interrupt
    retw

# Prints a null terminated string using BIOS interrupts.
# The address of the null terminated string must be in %bx
_PRINT_STR_16_:
    movb    $0xE, %ah   # Set to teletype
    testw   %bx, %bx    # Set ZF if %bx == 0
    je      L_END       # Exit if input was null
L_LOOP:
    movb    (%bx), %al  # Load one byte from address of %bx into %al
    int     $0x10       # Call BIOS interrupt
    incw    %bx
    testb   %al, %al    # Check for null terminator, set ZF if %al == 0
    jne     L_LOOP      # Jump to end if we reached the end of the string.
L_END:  
    retw
