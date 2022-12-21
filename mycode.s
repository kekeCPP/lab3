    .data
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
    .global getText2
    .global getOutPos
    .global setOutPos
    .global outImage
    .global putInt
    .global putText
    .global putChar
    .global main
inImage:
    movq    $inbuff, %rdi
    movq    $64, %rsi
    movq    stdin, %rdx
    call    fgets
    movq    $0, inbuffpos
    ret

getInt:
    call    getInPos
    movq    $inbuff, %rdi
    addq    %rax, %rdi      # %rdi = pointer to current position of inbuff
    movq    $0, %rax

lIgnoreSpaces:
    cmpb    $' ', (%rdi) # Compare character to blankspace
    je      blankspace

loop:
    cmpb    $'+', (%rdi) # Compare character to +
    je      blankspace
    cmpb    $'-', (%rdi) # Compare character to -
    je      negative
    cmpb    $'0', (%rdi)
    jl      end
    cmpb    $'9', (%rdi)
    jg      end
    movzbq  (%rdi), %r10
    subq    $'0', %r10
    imulq   $10, %rax
    addq    %r10, %rax
    incq    %rdi
    jmp     loop

blankspace:     # If blank space or + then go to next character
    incq    %rdi
    jmp     lIgnoreSpaces

negative:
    movzbq  (%rdi), %r11 # Put the - sign in a register
    incq    %rdi
    jmp     loop

negate:
    neg     %rax # Negate the number
    movq    $'/', %r11 # change the character in %r11 so we dont get an infinate loop

end:
    cmpq    $'-', %r11
    je      negate          # negate the number if there is a - sign in %r11
    subq    $inbuff, %rdi   # %rdi = the new position of inbuff
    call    setInPos        # set the new position
    ret


setInPos:
    #### Parameters ####
    # %edi = index to set position to
    movslq  %edi, %rdi      # sign extended 4-byte to 8-byte
    cmpq    $0, %rdi        # check if input < 0
    jl      jSetPosZero     # if yes set pos to 0
    cmpq    $63, %rdi       # check if input > 63
    jg      jSetPosMax      # if yes set pos to 63
    movq    %rdi, inbuffpos # else set pos to input
    ret

jSetPosZero:
    movq    $0, inbuffpos
    ret

jSetPosMax:
    movq    $63, inbuffpos
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

    cmpq    $0, (%rdi)     # Check if inbuff is empty
    je      cInImage
    cmpq    $63, %rax       # Check if we are at the last position of inbuff
    jg      cInImage

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

    movq    %rsi, %rdx      # %rdx = number of characters to read
    call    getInPos        # %rax = current position of inbuff
    movq    $inbuff, %rsi   # %rsi = pointer to outbuff
    addq    %rax, %rsi      # %rsi = pointer to current position in inbuff
    movq    $0, %rcx        # %rcx = characters read counter
    pushq   %rdi            # push initial value of %rdi to stack

lGetText:
    cmpq    %rcx, %rdx      
    je      rGetText2       # if chracters read = number of characters to read
    cmpq    $63, %rax
    jg      cGetText
    cmpb    $0, (%rsi)      # compare character in buf to null
    je      rGetText2       # if null return
    movq    (%rsi), %r10    # move character to temporary register
    movq    %r10, (%rdi)    # move character from temporary register to current position in inbuff
    incq    %rsi            # current position in inbuff++
    incq    %rax            # new position in inbuff++
    incq    %rdi            # position in buf++
    incq    %rcx            # characters read++
    jmp     lGetText        # read the next character

rGetText2:
    # movq    (%rsi), %r10    # move the null character to temporary register
    # movq    %r10, (%rdi)    # move the null character from temporary register to current position in inbuff
    pushq   %rdi            # push value in %rdi to stack because we need to change it for setInPos
    # incq    %rax            # new position in inbuff++
    movq    %rax, %rdi      # %rdi = new position in inbuff
    call    setInPos        # set the new position in the inbuff
    
    popq    %rdi            # pop the value of %rdi that we just pushed
    popq    %rsi            # pop the initial value of %rdi from the stack and store it in %rsi 
    subq    %rsi, %rdi      # current position in buf - start of buf. %rdi = number of characters transferred
    movq    %rdi, %rax      # return the amount of characters transferred     
    ret

cGetText:
    subq    %rax, %rsi      # reset the outbuff pointer back to the first position
    pushq   %rdi            # push the pointer in %rdi to the stack since outImage will change it
    call    inImage
    call    getInPos        # reset %rax position back to 0
    popq    %r11            # restore the pointer to the current position in buf from the stack into %r11
    movq    %r11, %rdi      # restore the pointer to the current position of buf to %rdi
    jmp     lGetText


getOutPos:
    #### Return Value ####
    # %rax = current position of outbuffer

    movq    outbuffpos, %rax
    ret


setOutPos:
    #### Parameters ####
    # %edi = index to set position to

    movslq  %edi, %rdi          # sign extend 4-byte to 8-byte
    cmpq    $0, %rdi            # check if input < 0
    jl      jSetOposZero        # if yes set pos to 0
    cmpq    $63, %rdi           # check if input > 63
    jg      jSetOposMax         # if yes set pos to 63

    movq    %rdi, outbuffpos    # else set pos to input
    ret

jSetOposZero:
    movq    $0, outbuffpos
    ret

jSetOposMax:
    movq    $63, outbuffpos
    ret

outImage:
    movq    $outbuff, %rdi
    call    puts
    movq    $0, %rdi
    call    setOutPos
    ret

putInt:
    #### Parameters ####
    # %edi = number to put in outbuff


    call    getOutPos
    movq    %rax, %r11      # %r11 = current position of outbuff
    movq    $outbuff, %r10  # %r10 = pointer to outbuff
    addq    %r11, %r10      # %r10 = pointer to current position in outbuff
    movslq  %edi, %rax      # move the 4-byte integer from the input into an 8-byte register and keep sign
    movq    $0, %rdi        # counter of numbers added
    movq    $10, %rbx       # divisor
    movq    $0, %rdx        # remainder


    cmpq    $0, %rax        # Check if number is negative or not
    jge     lPutInt         # if number >= 0 dont do anything
    negq    %rax            # else make it positive and add a '-' sign to the string
    movb    $'-', (%r10)
    incq    %r10

    
lPutInt:
    movq    $0, %rdx        # reset %rdx for each iteration
    divq    %rbx            # %rax / 10, %rax = quotient, %rdx = remainder
    addq    $48, %rdx       # turn remainder into ascii character
    pushq   %rdx            # push ascii character to stack
    incq    %rdi            # %rdi++
    cmpq    $0, %rax
    jnz     lPutInt         # loop if the quotient is larger than 0 (there are more numbers to read)
    movq    %rdi, %r11      # else save the counter in %r11 for later use     

rPutInt:     
    popq    (%r10)          # pop the last added ascii character from the stack and store it at outbuff[%r10]
    incq    %r10            # %r10++
    dec     %rdi            # decrement the counter of numbers to add (%rdi--)
    cmpq    $0, %rdi
    jnz      rPutInt         # jump if there are still more numbers to pop from the stack

    movq    $0, (%r10)      # else add a null character at the end of the string
    # addq    $1, %r11        # increment the counter of characters added
    # movq    $outbuff, %rax  # move outbuff to the return register (unnecessary because we don't care about return value from this function) 
    subq    $outbuff, %r10  # get the new postition of outbuff
    movq    %r10, %rdi      
    call    setOutPos       # set the new position in outbuff to outbuffpos + amount of numbers added + 1 for null character
    ret                     # return


putText:
    #### Parameters ####
    # %rdi = pointer to buf

    call    getOutPos       # %rax = current position of outbuff
    movq    $outbuff, %rsi  # %rsi = pointer to outbuff
    addq    %rax, %rsi      # %rsi = pointer to current position in outbuff

lPutText:
    cmpq    $63, %rax
    jg      cPutText
    cmpb    $0, (%rdi)      # compare character in buf to null
    je      rPutText        # if null return
    movq    (%rdi), %r10    # move character to temporary register
    movq    %r10, (%rsi)    # move character from temporary register to current position in outbuff
    incq    %rsi            # current position in outbuff++
    incq    %rax            # new position in outbuff++
    incq    %rdi            # position in buf++
    jmp     lPutText        # read the next character

rPutText:
    # movq    (%rdi), %r10    # move the null character to temporary register
    # movq    %r10, (%rsi)    # move the null character from temporary register to current position in outbuff
    # incq    %rax            # new position in outbuff++
    movq    %rax, %rdi      # %rdi = new position in outbuff
    call    setOutPos       # set the new position in the outbuff
    ret

cPutText:
    subq    %rax, %rsi      # reset the outbuff pointer back to the first position
    pushq   %rdi            # push the pointer in %rdi to the stack since outImage will change it
    call    outImage
    call    getOutPos       # reset %rax position back to 0
    popq    %r11            # restore the pointer to the current position in buf from the stack into %r11
    movq    %r11, %rdi      # restore the pointer to the current position of buf to %rdi
    jmp     lPutText

putChar:
    #### Parameters ####
    # %rdi = character to put in outbuff

    call    getOutPos       # %rax = current position in outbuff
    movq    $outbuff, %rsi  # %rsi = pointer to start of outbuff
    addq    %rax, %rsi      # %rsi = pointer to current position of outbuff

    movq    %rdi, (%rsi)    # copy the character into outbuff
    incq    %rax            # increment the position of outbuff
    movq    %rax, %rdi
    call    setOutPos
    cmpq    $64, %rdi
    jl      rPutChar

    call outImage

rPutChar:
    ret
