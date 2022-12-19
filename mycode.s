    .data
headMsg:	.asciz	"44Start av testprogram. Skriv in 5 tal!"
format:     .ascii  "%c\n"
buf:        .space  64
inbuff:     .space  64
outbuff:    .space  64
inbuffpos:  .quad   0
outbuffpos: .quad   0

    .text
    .global inImage
    .global getInt
    .global setInPos
    .global getInPos
    .global getChar
    .global getText
    .global getOutPos
    .global setOutPos
    .global putText
    .global outImage
    .global testFunction
    .global main
inImage:
    movq    $inbuff, %rdi
    movq    $64, %rsi
    movq    stdin, %rdx
    call    fgets
    movq    $0, inbuffpos
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


setInPos:
    #### Parameters ####
    # %rdi = index to set position to
    movq    %rdi, inbuffpos
    ret


getInPos:
    #### Return Value ####
    # %rax = current position of inbuffer
    movq    inbuffpos, %rax
    ret


getChar:
    #### Return Value ####
    # %rax = character that was read
    movq    $inbuff, %rdi
    call    getInPos        # get the current position of inbuff

    # cmpq    $0, %rax
    # je      cInImage
    cmpq    $0, (%rdi)     # Check if inbuff is empty
    je      cInImage
    cmpq    $63, %rax       # Check if we are at the last position of inbuff
    je      cInImage

fGetChar:
    movq    %rax, %r10      # store the value from getInPos for later use
    addq    %rax, %rdi      # move to the position of inbuffpos in inbuff
    movq    (%rdi), %rax    # move the character to %rax so we can return it
    
    incq    %r10            # %r10++
    movq    %r10, %rdi
    call    setInPos        # Set inbuffpos to the new value
    ret

cInImage:                   # Happens if buffer is empty(position is at 0) or position is at the end
    call    inImage         # Get new imput
    movq    $inbuff, %rdi   # Move the new inbuff generated from inImage to %rdi
    call    getInPos        # We need to call getInPos again because inImage will change the value of %rax
    jmp     fGetChar


getText:
    #### Parameters and return value ####
    # %rdi = buf
    # %rsi = number of characters to read
    # %rax = number of characters transferred
fGetText:
    movq    $inbuff, %rdx
    call    getInPos
    cmpq    $63, %rax
    je      cInImage2
    cmpq    $0, (%rdx)
    je      cInImage2


    movq    $0, %rcx
    addq    %rax, %rcx
    cmpq    $0, %rsi
    jg      lReadChar
    movq    %rcx, %rax
    ret

lReadChar:
    cmpq    $63, %rcx
    jg      rGetText        # Return if we are at the end of the buffer
    cmpq    $0, (%rdx)
    je      rGetText        # Return if there is nothing more to read
    
    addq    %rcx, %rdx      # [inbuff + number of characters transferred]
    addq    %rcx, %rdi
    movq    (%rdx), %rdi    # buf[number of characters transferred] = inbuff[number of characters transferred]
    incq    %rcx            # number of characters transferred++
    
    cmpq    %rcx, %rsi
    jg      lReadChar       # while number of characters to read > number of characters transferred
    movq    %rcx, %rax
    ret

rGetText:
    movq    %rcx, %rax
    ret

cInImage2:
    call    inImage
    jmp     fGetText


getOutPos:
    #### Return Value ####
    # %rax = current position of outbuffer
    movq    outbuffpos, %rax
    ret


setOutPos:
    #### Parameters ####
    # %rdi = index to set position to
    movq    %rdi, outbuffpos
    ret
