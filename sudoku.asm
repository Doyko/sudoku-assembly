	.data
grid:	.word 0, 0, 0, 0, 0, 0, 0, 0, 0,
	      0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0
size:	.word 81
n_int:	.word 9
size_block: .word 3

#####################################################
	.macro print_str (%str)	# macro for print %str
	.data
Label:	.asciiz %str
	.text
	li $v0, 4
	la $a0, Label
	syscall
	.end_macro

	.text
main:				# $t9, $t8, $t7 and $t6 are constant variables
	la $t9, grid		# $t9 <= grid
	la $t8, size
	lw $t8, 0($t8)		# $t8 <= size of grid
	la $t7, n_int
	lw $t7, 0($t7)		# $t7 <= numbers (9)
	la $t6, size_block
	lw $t6, 0($t6)		# $t6 <= size of block (3)
new:
	jal create		# call the function to create the grid

	li $t5, 0		# $t5 <= index being processed
	or $t3, $t9, $0		# $t3 <= pointer on this index
	li $v1, 0		# $v1 <= validity (1 if the grid is completed, 0 otherwise)

	jal solve		# call the function to solve
	bne $v1, $0, if_ok	# if $v1 != 0, the grid is completed
	print_str ("This grid can't be solved !\n")
	j end			# finish the program

if_ok:	jal display		# display grid
	j end			# finish the program

#####################################################
				# function to create the grid that uses registers $t0, $t1, $t2, $t3 and $t4
create:				# no argument, no return value
	subi $sp, $sp, 8	# extend the stack of 8 bytes
	sw $ra, 0($sp)		# save $ra
	sw $fp, 4($sp)		# save $fp
	addi $fp, $sp, 8	# adjust $fp
start_create:
	jal display
	print_str ("Enter the index of the block to modify (between 1 and 9, otherwise 0 to validate the grid):")
	li $v0, 5		# $v0 <= 5 to read an integer
	syscall
	bltz $v0, err1		# error if $v0 is less than 0
	subi $t3, $v0, 10
	bgez $t3, err1		# error if $v0 is more than 9
	or $t0, $v0, $0		# $t0 <= index of the block to modify
	beq $t0, $0, end_c	# if t0 == 0 then the function ends
	subi $t1, $t0, 1
	div $t1, $t6		# calculation of the index of the line
	mflo $t1
	mfhi $t2
	li $t3, 27
	multu $t1, $t3
	mflo $t1		# $t1 <= beginning of the line
	multu $t2, $t6
	mflo $t2
	add $t2, $t1, $t2	# $t2 <= index of the first integer of the block
choice_int:
	subi $sp, $sp, 12	# extend the stack of 12 bytes
	sw $t0, 0($sp)		# save $t0 (index of the block)
	sw $t2, 4($sp)		# save $t2 (index of the first integer of the block)
	sw $fp, 8($sp)		# save $fp
	addi $fp, $sp, 12	# adjust $fp
	jal display
	lw $t0, 0($sp)		# get back $t0
	lw $t2, 4($sp)		# get back $t2
	lw $fp, 8($sp)		# get back $fp
	addi $sp, $sp, 12	# reduce the stack
	print_str ("block of index  ")
	or $a0, $t0, $0		# $a0 <= index of the block to modify
	li $v0, 1		# print the index
	syscall
	print_str (" selected, enter the index of the number to modify (between 1 and 9, otherwise 0 to select an other block):")
	li $v0, 5		# $v0 <= 5 to read and integer
	syscall
	bltz $v0, err2		# error if $v0 is less than 0
	subi $t3, $v0, 10
	bgez $t3, err2		# error if $v0 is more than 9
	or $t1, $v0, $0		# $t1 <= index of the number to modify
	beq $t1, $0, start_create	# if $t1 == 0 then the program goes back to the beginning of the function
	subi $t3, $t1, 1
	div $t3, $t6		# calculation of the line of the number inside the block
	mflo $t1
	mfhi $t4
	multu $t1, $t9
	mflo $t1
	add $t1, $t1, $t4
	add $t1, $t1, $t2 	# $t1 <= index of the number to modify
	li $t4, 4
	multu $t1, $t4
	mflo $t4
	add $t4, $t4, $t9	# $t4 <= pointer on the number to modify
	print_str ("Enter the number to place :")
	li $v0, 5		# $v0 <= 5 to read and integer
	syscall
	bltz $v0, err2		# error if $v0 is less than 0
	subi $t3, $v0, 10
	bgez $t3, err2		# error if $v0 is more than 9
	or $a2, $v0, $0		# $a2 <= value to check
	beq $a2, $0, place_int	# if $a2 == 0, no need to check
	div $t1, $t7
	mflo $a0		# $a0 <= index of the line
	mfhi $a1		# $a1 <= index of the column
	or $a2, $v0, $0		# $a2 <= value to check
	subi $sp, $sp, 12	# extend the stack of 12 bytes
	sw $t0, 0($sp)		# save $t0 (index of the block)
	sw $t2, 4($sp)		# save $t2 (index of the first integer of the block)
	sw $fp, 8($sp)		# save $fp
	addi $fp, $sp, 12	# adjust $fp
	jal check
	lw $t0, 0($sp)		# get back $t0
	lw $t2, 4($sp)		# get back $t2
	lw $fp, 8($sp)		# get back $fp
	addi $sp, $sp, 12	# reduce the stack
	beq $v0, $0, err3	# if $v0 == 0, the value is already on the line, column or block
place_int:
	sw $a2, 0($t4)
	j choice_int
err1:
	print_str ("Error : incorrect input ! :(\n")
	j start_create
err2:
	print_str ("Error : incorrect input ! :(\n")
	j choice_int
err3:
	print_str ("Error : the value is already on the line, column or block ! :(\n")
	j choice_int

end_c:
	lw $ra, 0($sp)		# get back $ra
	lw $fp, 4($sp)		# get back $fp
	addi $sp, $sp, 8	# reduce the stack
	print_str ("Grid resolution in progress, it may take a moment ...\n")
	jr $ra

#####################################################
				# function to solve the gird that used registers $t0, $t3, $t4 and $t5
solve:				# no argument, $v1 <= return value (1 if the grid is completed, 0 otherwise)
	subi $sp, $sp, 24	# extend the stack of 24 bytes
	sw $ra, 0($sp)		# save $ra
	sw $t4, 4($sp)		# save $t4
	sw $a0, 8($sp)		# save $a0
	sw $a1, 12($sp)		# save $a1
	sw $fp, 20($sp)		# save $fp

	bne $t5, $t8, not_finish# if $t5 == $t8, it's over
	li $v1, 1		# $v1 <= 1
	j return
not_finish:
	lw $t0, 0($t3)
	beq $t0, $0 processing	# the integer is processed if it is different than zero
	addi $t5, $t5, 1	# increase the index of the processed integer by 1
	addi $t3, $t3, 4	# move the pointer to the next integer
	jal solve
	bne $v1, $0, return	# if $v1 == 1, the processing is over
	subi $t5, $t5, 1	# decrease the index of the processed integer by 1
	subi $t3, $t3, 4	# move the pointer to the previous integer
	j return
processing:
	li $t4, 0		# $t4 <= counter 0-9 for integers to place
	div $t5, $t7
	mflo $a0		# $a0 <= index of the line
	mfhi $a1		# $a1 <= index of the column
for_proc:
	addi $t4, $t4, 1	# increase the counter of integer to place by 1
	or $a2, $t4, $0		# $a2 <= value to check
	sw $t3, 16($sp)		# save $t3
	jal check		# check
	lw $t3, 16($sp)		# get back $t3
	beq $v0, $0, end_proc	# if the check is ok, the value is place and the program continue, otherwise the next value is checked
	sw $t4, 0($t3)
	addi $t5, $t5, 1	# increase the index of the processed integer by 1
	addi $t3, $t3, 4	# move the pointer to the next integer
	jal solve
	bne $v1, $0, return	# if $v1 == 1, the processing is over
	subi $t5, $t5, 1	# decrease the index of the processed integer by 1
	subi $t3, $t3, 4	# move the pointer to the previous integer
	sw $0, 0($t3)		# put a 0 back
end_proc:
	bne $t4, $t7 for_proc	# if $t4 == $t7 the processing continue
return:
	lw $ra, 0($sp)		# get back $ra
	lw $t4, 4($sp)		# get back $t4
	lw $a0, 8($sp)		# get back $a0
	lw $a1, 12($sp)		# get back $a1
	lw $fp, 20($sp)		# get back $fp
	addi $sp, $sp, 24	# reduce the stack
	jr $ra

#####################################################
				# function to check the value that uses registers $t0, $t1, $t2 and $t3
check:				# $a0 <= index of the line | $a1 <= index of the column | $a2 <= value to check | $v0 <= return value (1 if the value is here, 0 otherwise)
	# check_ligne
	multu $a0, $t7
	mflo $t3		# $t3 <= index of the first integer of the line
	li $t0, 4
	multu $t3, $t0
	mflo $t3
	add $t3, $t3, $t9	# $t3 <= pointer on the first integer of the line
	li $t0, 0		# $t0 <= counter 0-9 for the line
for_c_ligne:
	lw $t1, 0($t3)		# load the value to compare
	beq $t1, $a2, end_0	# if $t1 == $a2 exit the check
	addi $t0, $t0, 1	# increase the counter by 1
	beq $t0, $t7, check_col	# if $t0 == 9, check the column
	addi $t3, $t3, 4	# $t3 <= pointer on the next integer of the line
	j for_c_ligne

check_col: 			# check column
	li $t0, 4
	multu $a1, $t0
	mflo $t3
	add $t3, $t3, $t9	# $t3 <= pointer on the first integer of the column
	li $t0, 0		# $t0 <= counter 0-9 for the column
for_c_col:
	lw $t1, 0($t3)		# load the value to compare
	beq $t1, $a2, end_0	# if $t1 == $a2 exit the check
	addi $t0, $t0, 1	# increase the counter by 1
	beq $t0, $t7, check_bloc# if $t0 == 9, check the block
	addi $t3, $t3, 36	# $t3 <= pointer on the next integer of the column
	j for_c_col

check_bloc:			# check bloc
	div $a0, $t6
	mflo $t3
	li $t0, 27
	multu $t3, $t0
	mflo $t3
	div $a1, $t6
	mfhi $t0
	add $t3, $t3, $a1
	sub $t3, $t3, $t0 	# $t3 <= index of the first integer of the block
	li $t0, 4
	multu $t3, $t0
	mflo $t3
	add $t3, $t3, $t9	# $t3 <= pointer to the first integer of the block
	li $t0, 0 		# $t0 <= counter 0-9 for the block
	li $t1, 0 		# $t1 <= counter 0-3 for the line of the block
for_c_bloc:
	lw $t2, 0($t3)		# load the value to compare
	beq $t2, $a2, end_0	# if $t2 == $a2 exit the check
	addi $t0, $t0, 1	# increase the counter for the block by 1
	beq $t0, $t7, end_1	# if $t0 != 9 continue to check
	addi $t1, $t1, 1	# increase the counter for the line by 1
	bne $t1, $t6, same_lig	# if $t1 != 3 continue the check on the same line
	li $t1, 0		# reset the counter for the line
	addi $t3, $t3, 24	# move the pointer to the next value to check
same_lig:
	add $t3, $t3, 4		# $t3 <= pointer on the next integer of the block
	j for_c_bloc

end_0:
	li $v0, 0		# $v0 <= 0
	jr $ra

end_1:
	li $v0, 1		# $v0 <= 1
	jr $ra

#####################################################
				# function to show the grid that uses registers $t0, $t1, $t2, $t3 and $t5
display:			# no argument, no return value
	or $t5, $t9, 0		# $t5 <= pointer on the processed integer
	li $t0, 0		# $t0 <= counter 0-81 for the grid
	li $t1, 0		# $t1 <= counter 0-9 for the \n
	li $t2, 0		# $t2 <= counter 0-3 for the column
	li $t3, 0		# $t3 <= counter 0-3 for the line
for_display:
	lw $a0, 0($t5)		# load the integer
	li $v0, 1		# print the integer
	syscall
	addi $t0, $t0, 1	# increase the counter for the grid by 1
	beq $t0, $t8, end_d	# if $t0 == 81 end the function
	addi $t1, $t1, 1	# increase the counter for the \n by 1
	addi $t2, $t2, 1	# increase the counter for the column by 1

	bne $t1, $t7, no_bsn	# if $t1 != 9 don't print the \n
	li $a0, 0xA		# otherwise, $a0 <= \n
	li $v0, 11		# print \n
	syscall
	addi $t3, $t3, 1	# increase the counter for the line 1
	li $t1, 0		# reset the counter for the \n
	li $t2, 0		# reset the counter for the column
no_bsn:
	bne $t2, $t6, no_pipe	# if $t2 != 3 don't print the |
	li $a0, 0x7C		# otherwise, $a0 <= |
	li $v0, 11		# print |
	syscall
	li $t2, 0		# reset the counter for the \n
no_pipe:
	bne $t3, $t6, no_lig	# if $t3 != 3 don't print the line
	print_str ("---+---+---\n")
	li $t3, 0		# reset the counter for the line
no_lig:
	addi $t5, $t5, 4	# $t5 <= pointer on the next integer
	j for_display
end_d:
	li $a0, 0xA		# $a0 <= \n
	li $v0, 11		# print \n
	syscall
	jr $ra

#####################################################
				# function to end the program that uses registers $t0 et $t1
end:				# no argument, no return value
	print_str ("Would you like to enter a new grid? (1 for yes, 0 for no):")
	li $v0, 5		# $v0 <= 5 to read an integer
	syscall
	li $t0, 1
	bne $v0, $t0 bye	# if $v0 == 1 end the program
	li $t0, 0		# $t0 <= counter 0-81 to reset the grid
	or $t1, $t9, $0		# $t1 <= pointer on the grid
for_reset:
	sw $0, 0($t1)		# put a 0
	addi $t0, $t0, 1	# increase the counter by 1
	addi $t1, $t1, 4	# $t1 <= pointer to the next integer of the grid
	bne $t0, $t8, for_reset	# if $t0 != $t8 continue
	j new
bye:
	print_str ("Bye :)\n")
	li $v0, 10		# exit the program
	syscall
