.data
	user_input: .space 100
	too_large: .asciiz "Input is too long."
	is_empty: .asciiz "Input is empty."
	is_invalid: .asciiz "Invalid base-34 number."
.text
    main:
	li $v0, 8   #used to get user input as text and displays it
	la $a0, user_input
	li $a1, 100
