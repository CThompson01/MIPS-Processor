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
nop
nop # RAW hazard

#add
add $11, $6, $5     # $11 = $6 + $5 | 11
add $12, $4, $3     # $12 = $4 + $3 | 7
add $13, $2, $1     # $13 = $2 + $1 | 3
nop # RAW hazard $12
add $14, $11, $12   # $14 = $11 + $12 | 18
nop
nop # RAW hazard
add $15, $14, $13   # $15 = $14 + $13 | 21

#sub
sub $7, $6, $1      # $6 - $1 in $7 | 5
sub $8, $5, $2      # $5 - $2 in $8 | 3
sub $9, $4, $3      # $4 - $3 in $9 | 1
nop
nop # RAW hazard
sub $10, $9, $zero  # $9 - $zero in $10 | 1

#slt
slt $1, $1, $2      # $1 < $2 | 1
nop
nop # WAR hazard (might need 1)
slt $2, $4, $3      # $4 < $3 | 0
nop
nop # WAR hazard
slt $3, $5, $6      # $5 < $6 | 1

#slti
slti $1, $1, 5      # $1 < 5 | 1
slti $2, $4, 2      # $4 < 2 | 0
slti $3, $5, 14     # $5 < 14 | 1
nop
nop # RAW hazard

#and
and $1, $1, $3
and $7, $7, $8
and $11, $10, $9

#andi
# WAW but we PROBABLY don't need to worry about that
andi $2, $zero, 0x00ff
andi $2, $3, 0x00ff
andi $2, $3, 0

#or
# WAW but we PROBABLY don't need to worry about that
or $s1, $1, $zero   # | 1
or $s1, $1, $3      # | 0
or $s1, $2, $zero   # | 0
or $s1, $2, $1      # | 1

#ori
# WAW but we PROBABLY don't need to worry about that
ori $s2, $zero, 0x1234  # | 1  
ori $s2, $zero, 0       # | 0
ori $s2, $6, 0x1234     # | 0

#nor
# WAW but we PROBABLY don't need to worry about that
nor $3, $4, $5
nor $3, $zero, $1
nor $3, $5, $5

#xor
xor $2, $zero, $4
xor $3, $3, $4
nop
nop # WAR hazard
xor $3, $s2, $s1

#xori
xori $2, $2, 1
nop
nop # RAW
xori $2, $2, 0
nop
nop # WAR
xori $2, $zero, 0
nop
nop # RAW

#sll
sll $2, $2, 8
nop
nop # RAW
sll $2, $2, 1
sll $3, $3, 4
nop
nop # WAR

#srl
srl $3, $2, 1
nop
nop # RAW
srl $3, $3, 5
nop
nop # WAR
srl $3, $2, 8
nop
nop # RAW

#sra
sra $3, $3, 1
nop
nop # WAR
sra $3, $2, 8
nop
nop # RAW
sra $2, $3, 4
nop
nop # WAR

#lui
lui $3, 5
lui $3, 10

halt