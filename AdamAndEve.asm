# On boot the BIOS does not know how to load the OS
# so the boot sector must do that. The boot sector is stored
# in a known location. That is the first sector of the disk,
# which is cylinder 0, header 0 and sector 0.
# The size of the boot sector is 512 bytes.
# To mark the region as bootable, the 511th and 512th byte must be a magic byte.
# So the 511th byte must be 0x55, and the 512th byte must be 0xAA, a 16 bit value.
# Because x86 is little endian, we need to store them in reverse order

# Naming conventions:
# Where $MODE is the processor mode such as RM (Real Mode) or PM (Protected Mode) etc..
# Where $NAME is the identifier name
# Procedures    -> _$MODE_$NAME
# Labels        -> __$MODE_$NAME
# Variables     -> ___$MODE_$NAME

.text
.code16 # we are using 16 bit mode
.global _RM_ENTRY_

################################ ENTRY ################################

# This is the main entry of our bootloader.
# We are in 16-bit real mode,
# 8 and 16 bit registers only, we can use segmentation, no virtual memory, no paging.
_RM_ENTRY:
    movw    $___RM_INFO, %si
    callw   _RM_PRINT_STR
    movw    $___RM_WELCOME, %si
    callw   _RM_PRINT_STR
    __RM_ENTRY:
        jmp __RM_ENTRY

################################ ROUTINES ################################

# This routine does a warm reboot.
# This is done by jumping to the reset vector.
# This basically means that the system will execute the code from the
# first insturction again without actually rebooting.
_RM_REBOOT:
    ljmpw $0xFFFF, $0x0

_RM_ERROR:
    movw    $___RM_ERROR, %si
    callw   _RM_PRINT_STR
    __RM_ERROR:
        jmp __RM_ERROR

# Prints a single 8-bit ASCII character using BIOS interrupts.
# The char to print must be in %al
_RM_PUTCHAR:
    movb    $0x0E, %ah  # Set to teletype
    int     $0x10       # Call BIOS interrupt
    retw

# Prints a null terminated string using BIOS interrupts.
# The address of the null terminated string must be in %si
_RM_PRINT_STR:
    movb    $0x0E, %ah              # Set to teletype
    testw   %si, %si                # Set ZF if %si == 0
    je      __RM_PRINT_STR_END      # Exit if input was null
__RM_PRINT_STR_LOOP:
    movb    (%si), %al              # Load one byte from address of %si into %al
    int     $0x10                   # Call BIOS interrupt
    incw    %si                     # Increment pointer, move to next character byte
    testb   %al, %al                # Check for null terminator, set ZF if %al == 0
    jne     __RM_PRINT_STR_LOOP     # Jump to end if we reached the end of the string.
__RM_PRINT_STR_END:  
    retw

################################ DATA ################################

___RM_INFO:         .asciz "AdamAndEve tiny x86 legacy bootloader (C) Mario Sieg \"pinsrq\" <mt3000@gmx.de>\r\n"
___RM_WELCOME:      .asciz "Booted into 16-bit real mode!\r\n"
___RM_ERROR:        .asciz "Unknown real mode boot loader error!\r\n"

.fill 510-(.-_RM_ENTRY), 1, 0   # Fill the rest of the bytes with zeroes
.word 0xAA55                    # The 2 magic bytes 0x55AA but because x86 is little endian, we need to swap them.
