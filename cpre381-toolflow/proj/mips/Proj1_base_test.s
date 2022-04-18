#
# Base Processor Tests 
#

#addi 
addi  $1,  $0,  1	# Place 1 in $1 | 1
addi  $2,  $0,  2	# Place 2 in $2 | 2
addi  $3,  $0,  3	# Place 3 in $3 | 3
addi  $4,  $0,  4	# Place 4 in $4 | 4
addi  $5,  $0,  5	# Place 5 in $5 | 5
addi  $6,  $0,  6	# Place 6 in $6 | 6

#add
add $11, $6, $5     # $11 = $6 + $5 | 11
add $12, $4, $3     # $12 = $4 + $3 | 7
add $13, $2, $1     # $13 = $2 + $1 | 3
add $14, $11, $12   # $14 = $11 + $12 | 18
add $15, $14, $13   # $15 = $14 + $13 | 21

#sub
sub $7, $6, $1      # $6 - $1 in $7 | 5
sub $8, $5, $2      # $5 - $2 in $8 | 3
sub $9, $4, $3      # $4 - $3 in $9 | 1
sub $10, $9, $zero  # $9 - $zero in $10 | 1

#slt
slt $1, $1, $2      # $1 < $2 | 1
slt $2, $4, $3      # $4 < $3 | 0
slt $3, $5, $6      # $5 < $6 | 1

#slti

#and

#andi

#or

#ori
ori $s2, $zero, 0x1234
ori $s2, 0x4321, $zero
ori $s2, $zero, $zero
ori $s2, $6, 0x1234

#nor

#xor

#xori

#sll

#srl

#sra

#lui

halt