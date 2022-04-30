#
# Logical Jump Tests 
#
.text

#call the stack 5 times and return 

addi $sp, $0, 0x7FFFF000

jal call1


halt 

call1:
    addi $sp, $sp, 4
    sw $ra, 0($sp)
    jal call2
    
    lw $ra, 0($sp)
    addi $sp, $sp -4
    
    jr $ra

call2:
    addi $sp, $sp, 4
    sw $ra, 0($sp)

    jal call3

    lw $ra, 0($sp)
    addi $sp, $sp -4

    jr $ra

call3:
    addi $sp, $sp, 4
    sw $ra, 0($sp)

    jal call4

    lw $ra, 0($sp)
    addi $sp, $sp -4

    jr $ra

call4: 
    addi $sp, $sp, 4
    sw $ra, 0($sp)

    jal call5

    lw $ra, 0($sp)
    addi $sp, $sp -4

    jr $ra

call5: 
    jr $ra
