# Author - Braedon Giblin <bgiblin@iastate.edu>
# Date   - 03/27/20
# File   - bubbleSort.s
.data
inString: .word 1,4,6,4,9,3,6,8,52,12,54
.text
.globl main
main:
        lui $sp, 0x7FFF
        ori $sp, 0xEFFC

	lui $1, 4097
	ori $4, $1, 0
	li $a1 11 # inString length
	
	jal bubbleSort
	j exit


swap:
	# Takes two params, $a2 and $a3, both pointers, and swaps the values
	lw $t6 0($a2)
	lw $t7 0($a3)
	sw $t6 0($a3)
	sw $t7 0($a2)
	jr $ra

bubbleSort:
	# Bubblesorts an array. 
	# Params -
	# $a0 contains pointer to array
	# $a1 contains size of array
	# No return -- Sorts in place
	addi $sp, $sp, -4
	sw $ra, 0($sp)	# Save return address to stack
	
	# int i = 0
	addi $t5, $0, 0
	L1Condition: #i < n - 1
		beq $t5, $a1 endL1
		addi $t3, $a0, 0 # j = 0
		sub $t4, $a1, $t5 
		sll $t4, $t4, 2 # Multiply address by 4
		add $t4, $t4, $a0
		L2Condition: # j < n - i -1
			beq $t4, $t3 endL2
			lw $a2, 0($t3)
			lw $a3, 4($t3)
			slt $t0, $a2, $a3
			bne $t0, $zero, noswap
			addi $a2, $t3, 0
			addi $a3, $t3, 4
			jal swap
			noswap:
			addi $t3, $t3, 4
			j L2Condition
		endL2:
		addi $t5, $t5, 1
		j L1Condition
	
	endL1: # Jump target for loop esacpe
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

exit:
    # Exit program
    li $v0, 10
    syscall
    halt
