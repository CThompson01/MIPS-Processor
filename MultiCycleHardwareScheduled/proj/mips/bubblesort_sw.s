# Author - Braedon Giblin <bgiblin@iastate.edu>
# Date   - 03/27/20
# File   - bubbleSort.s
.data
inString: .word 1,4,6,4,9,3,6,8,52,12,54
.text
.globl main
main:
        lui $sp, 0x7FFF
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
        ori $sp, 0xEFFC

	lui $1, 4097
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	ori $4, $1, 0
	li $a1 11 # inString length
	
	jal bubbleSort
	nop #Control hazard fix: Prevent the next write instruction in memory from 
	    #being executed after the jump instr	
	j exit
	nop #Control hazard fix: Prevent the next write instruction in memory from 
	    #being executed after the jump instr


swap:
	# Takes two params, $a2 and $a3, both pointers, and swaps the values
	lw $t6 0($a2)
	lw $t7 0($a3)
	nop #Data hazard avoidance: needs 3 cycles for mem writes to complete
	nop #Data hazard avoidance: needs 3 cycles for mem writes to complete
	# Another nop is not necessary because another memory location ($t7) is being written to
	sw $t6 0($a3)
	sw $t7 0($a2)
	jr $ra
	# No need to add nop: the next instruction is already nop

bubbleSort:
	# Bubblesorts an array. 
	# Params -
	# $a0 contains pointer to array
	# $a1 contains size of array
	# No return -- Sorts in place
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	addi $sp, $sp, -4
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
	sw $ra, 0($sp)	# Save return address to stack
	
	# int i = 0
	addi $t5, $0, 0
	L1Condition: #i < n - 1
		nop #Data hazard avoidance: $t5 is written to in line 90
		nop # needs 3 cycles for reg writes to complete
		nop
		beq $t5, $a1 endL1
		nop #Control hazard fix: Wait to ensure beq is finished before writing to memory/regs
		addi $t3, $a0, 0 # j = 0
		sub $t4, $a1, $t5 
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		sll $t4, $t4, 2 # Multiply address by 4
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
		add $t4, $t4, $a0
		L2Condition: # j < n - i -1
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			beq $t4, $t3 endL2
			nop #Control hazard fix: Wait to ensure beq is finished before writing to memory/regs
			lw $a2, 0($t3)
			lw $a3, 4($t3)
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			nop #Data hazard avoidance: needs 3 cycles for reg writes to complete
			slt $t0, $a2, $a3
			nop
			nop
			nop
			bne $t0, $zero, noswap
			nop #Control hazard fix: Wait to ensure beq is finished before writing to memory/regs
			addi $a2, $t3, 0
			addi $a3, $t3, 4
			jal swap
			nop #Control hazard fix: Prevent the next write instruction in memory from 
			    #being executed after the jump instr
			noswap:
			addi $t3, $t3, 4
			j L2Condition
			nop #Control hazard fix: Prevent the next write instruction in memory from 
			    #being executed after the jump instr
		endL2:
		addi $t5, $t5, 1
		j L1Condition
		nop #Control hazard fix: Prevent the next write instruction in memory from 
		    #being executed after the jump instr	
		
	
	endL1: # Jump target for loop esacpe
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	nop #Data hazard needs 3 instructions
	nop #Data hazard needs 3 instructions
	jr $ra
	nop #Control hazard fix: Prevent the next write instruction in memory from 
	    #being executed after the jump instr

exit:
    # Exit program
    li $v0, 10
    syscall
    halt
