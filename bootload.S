.code16
.global start
start:
    cli
    movw    %cs, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %ss
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

Dispstr:
    movw    msg, %ax
    movw    %ax, %bp
    movw    $0x10, %cx
    movw    $0x1301, %ax
    movw    $0xc, %bx
    movw    $0, %dx
    int    $0x10
msg:
   .string "sdffd"
# switch to protect mode;


