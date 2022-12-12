    .data
headMsg:	.asciz	"44Start av testprogram. Skriv in 5 tal!"
format:     .ascii  "%c\n"
buf:        .space  64
inbuff:     .space  64
outbuff:    .space  64
inbuffpos:  .quad   12
outbuffpos: .quad   0

    .text
    .global testFunction
    .global inImage
    .global getInt
    .global putText
    .global outImage
    .global main
inImage:
    movq    $inbuff, %rdi
    movq    $64, %rsi
    movq    stdin, %rdx
    call    fgets
    movq    %rdi, %rax
    ret

getInt:
    movq    $0, %rax
    movq    $inbuff, %rdi
loop:
    cmpb    $' ', (%rdi) # Compare character to blankspace
    je      blankspace
    cmpb    $'+', (%rdi) # Compare character to +
    je      blankspace
    cmpb    $'-', (%rdi) # Compare character to -
    je      negative
    cmpb    $'0', (%rdi)
    jl      end
    cmpb    $'9', (%rdi)
    jge     end
    movzbq  (%rdi), %r10
    subq    $'0', %r10
    imulq   $10, %rax
    addq    %r10, %rax
    incq    %rdi
    jmp     loop
blankspace:     # If blank space or + then go to next character
    incq    %rdi
    jmp     loop
negative:
    movzbq  (%rdi), %r11 # Put the - sign in a register
    incq    %rdi
    jmp     loop
negate:
    neg     %rax # Negate the number
    movq    $'/', %r11 # change the character in %r11 so we dont get an infinate loop
end:
    cmpq    $'-', %r11
    je      negate
    ret
putText:


outImage:
    movq    %rax, %rdi
    call    puts
    ret
