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
.code16 # we are using 16 bit protected mode
.global _RM_ENTRY_

################################ ENTRY ################################

# This is the main entry of our bootloader.
# We are in 16-bit real mode,
# 8 and 16 bit registers only, we can use segmentation, no virtual memory, no paging.
_RM_ENTRY:
    JMP _RM_MAIN

    .space 3 - (.-_RM_ENTRY)
    # Configuration for a 2.88MB floppy using FAT 12
    OEMname:               .ascii      "BOOSTER "
    ___BytesPerSector:     .word       512
    ___SectPerCluster:     .byte       1
    ___ReservedSectors:    .word       1
    ___NumFAT:             .byte       2
    ___NumRootDirEntries:  .word       240
    ___NumSectors:         .word       5760
    ___MediaType:          .byte       0xf0
    ___NumFATsectors:      .word       9
    ___SectorsPerTrack:    .word       36
    ___NumHeads:           .word       2
    ___NumHiddenSectors:   .long       0
    ___NumSectorsHuge:     .long       0
    ___DriveNum:           .byte       0
    ___Reserved:           .byte       0x00
    ___Signature:          .byte       0x29
    ___VolumeID:           .long       0x54428E71
    ___VolumeLabel:        .ascii      "NO NAME    "
    ___FileSysType:        .ascii      "FAT12   "

_RM_MAIN:
    MOVW    $___RM_WELCOME, %SI
    CALLW   _RM_PRINT_STR
    __RM_ENTRY:
        JMP __RM_ENTRY

################################ ROUTINES ################################

# This routine does a warm reboot.
# This is done by jumping to the reset vector.
# This basically means that the system will execute the code from the
# first insturction again without actually rebooting.
_RM_REBOOT:
    LJMPW $0xFFFF, $0x0

_RM_ERROR:
    MOVW    $___RM_ERROR, %SI
    CALLW   _RM_PRINT_STR
    __RM_ERROR:
        JMP __RM_ERROR

# Prints a single 8-bit ASCII character using BIOS interrupts.
# The char to print must be in %al
_RM_PUTCHAR:
    MOVB    $0x0E, %AH  # Set to teletype
    INT     $0x10       # Call BIOS interrupt
    RETW

# Prints a null terminated string using BIOS interrupts.
# The address of the null terminated string must be in %si
_RM_PRINT_STR:
    MOVB    $0x0E, %AH              # Set to teletype
    TESTW   %SI, %SI                # Set ZF if %si == 0
    JE      __RM_PRINT_STR_END      # Exit if input was null
__RM_PRINT_STR_LOOP:
    MOVB    (%SI), %AL              # Load one byte from address of %si into %al
    INT     $0x10                   # Call BIOS interrupt
    INCW    %SI                     # Increment pointer, move to next character byte
    TESTB   %AL, %AL                # Check for null terminator, set ZF if %al == 0
    JNE     __RM_PRINT_STR_LOOP     # Jump to end if we reached the end of the string.
__RM_PRINT_STR_END:  
    RETW

################################ DATA ################################

___RM_WELCOME:      .asciz "\rBooted into 16-bit real mode!\n"
___RM_ERROR:        .asciz "\rUnknown real mode boot loader error!\n"

.fill 510-(.-_RM_ENTRY), 1, 0   # Fill the rest of the bytes with zeroes
.word 0xAA55                    # The 2 magic bytes 0x55AA but because x86 is little endian, we need to swap them.
