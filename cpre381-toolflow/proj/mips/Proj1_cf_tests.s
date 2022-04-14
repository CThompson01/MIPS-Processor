#
# Logical Jump Tests 
#

# data section
.data

# code/instruction section
.text

jal dumb
ori $s3 $zero 0x1234
beq $s1, 1, jeffspizza #issue here
bne $s1, 0, urmom
j exit

urmom:
    jr $ra

jeffspizza:
    jr $ra

dumb:
    addi $s1, $0, 1
    jr $ra

exit:
    halt