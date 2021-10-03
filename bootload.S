#include "boot.h"
#include "mmu.h"
.code16
.global start
start:
    cli
    xor     %ax,%ax
    #movw    %cs, %ax
    ljmp    $0, $entry

entry:
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %ss
    movw    $0x8000, %sp
    call    _getmmap

# Open A20
seta20.1:
    inb    $0x64, %al
    testb  $0x2, %al
    jnz    seta20.1
    
    movb   $0xd1, %al
    outb   %al, $0x64

seta20.2:
    
    inb    $0x64, %al
    testb  $0x2, %al
    jnz    seta20.2
    
    movb   $0xdf, %al
    outb   %al, $0x60
    movw   $_getmmap, %bp
    call   %bp
    lgdt   gdtdesc
    movl   %cr0, %eax
    orl    $CR0_PE, %eax
    movl   %eax, %cr0
    ljmp   $(SEG_KCODE<<3), $start32

_getmmap:
    push    %ds
    push    %es
    push    %ss
    movl    $0, %esi
    movl    $E80MAP_NR, %edi
    movl    %esi, (%edi)
    movl    $E80MAP_ADRADR, %edi 
    movl    $E80MAP_ADR, (%edi)
    xor     %ebx, %ebx
    movl     $E80MAP_ADR, %edi
loop:
    movl    0xe820, %eax
    movl    $0x14, %ecx
    movl    $0x0534d4150, %edx
    int     $0x15
    jc      .1

    add     0x14, %edi
    push    %eax
    movl    $(E80MAP_ADR+0x1000), %eax
    cmp     %edi, %eax
    pop     %eax
    jg      .1

    inc     %esi
    cmp     %edx, 0
    jne     loop

    jmp     .2

.1:
    mov     0, %esi
.2:
    movl    $E80MAP_NR, %edi
    movl    %esi, (%edi)
    pop     %ss
    pop     %es
    pop     %ds
    ret

.code32
start32:
    movw   $(SEG_KDATA<<3), %ax
    movw   %ax, %ds
    movw   %ax, %es
    movw   %ax, %ss
    movw   $0, %ax
    movw   %ax, %fs
    movw   %ax, %gs

    movl   $start, %esp
    #call bootmain

    movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
    movw    %ax, %dx
    outw    %ax, %dx
    movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
     outw    %ax, %dx
spin:
     jmp     spin



.p2align 2
gdt:
    SEG_NULLASM
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)
    SEG_ASM(STA_W, 0x0,0xffffffff)

gdtdesc:
    .word   (gdtdesc - gdt - 1)
    .long   gdt



#Dispstr:
#    movw    $0x7c30, %ax
#    movw    %ax, %bp
#    movw    $0x10, %cx
#    movw    $0x1301, %ax
#    movw    $0xc, %bx
#    movw    $0, %dx
#    int    $0x10
#msg:
#   .string "sdffd"
# switch to protect mode;


