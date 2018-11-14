.data
	user_input: .space 100
	too_large: .asciiz "Input is too long."
	is_empty: .asciiz "Input is empty."
	is_invalid: .asciiz "Invalid base-34 number."
.text
    main:
	li $v0, 8              #used to get user input as text and displays it
	la $a0, user_input
	li $a1, 100
	syscall
		
	# Remove leading spaces
	remove_space_before:
	li $t9, 32                      # save space char to t9
	lb $t5, 0($a0)                  # load first input char into t5
	beq $t9, $t5, remove_first_char # remove the first char if it is a space
	move $t5, $a0                   # if not a space save new input begining address into t5
	j remove_trailing_spaces
	
	remove_first_char:
	addi $a0, $a0, 1
	j remove_space_before
	
	# Remove trailing spaces
	remove_trailing_spaces:
	la $t8, user_input
	sub $t8, $t5, $t8   # Save the offset of the new starting position and beginning of input buffer 
	li $t7, 0           #initialize index of last non-space character 
	li $t9, 0           #intialize current index

	rts_loop:
	add $t4, $t8, $t9
	addi $t4, $t4, -100
	beqz $t4, end_rts        # End if the end of the string buffer has been reached
	add $t4, $t9, $a0        # Get address of current index 
	lb $t4, 0($t4)           # Load char from current index into t4
	beq $t4, $zero, end_rts  # Exit loop to check_Length if string terminates
	addi $t4, $t4, -10
