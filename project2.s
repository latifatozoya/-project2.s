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
