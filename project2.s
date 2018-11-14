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
	beqz $t4, end_rts        # end loop if endline character reached
	addi $t4, $t4, -22
	bnez $t4, update_last_character_index   #branch to update last character if the character isnt a space
	
	rts_loop_increment:
	addi $t9, $t9, 1     #Increment current index 
	j rts_loop
	
	update_last_character_index:
	move $t7, $t9        #save the current index into the last index 
	j rts_loop_increment
	
	end_rts:
	add $t4, $zero, $a0  # Get address of begining of user input
	add $t4, $t4, $t7    # Get address of the last non-space character
	addi $t4, $t4, 1     # Get address of character after last non-space characnter
	sb $zero, 0($t4)     # Null Terminate string after last non-space character
	j check_Length

	#Check length of string, this obtains the length of the string
        check_Length:
        li $t1, 0              #Initialize count at 0
        add $a0, $t5, $zero
         
	length_loop:
	lb $t8, 0($a0)                 #load the next char to t8
	or $t7, $t8, $t1   
	beq $t7, $zero, emptyError     #end the loop if equal to zero
	beq $t8, $zero, complete       #end loop if end-of-line is reached
	addi $a0, $a0, 1               #increments the string pointer 
	addi $t1, $t1, 1               #increments the count
	j length_loop

	#Execute if end of string has been reached
	complete:
	slti $t2, $t1, 5
	beq $t2, $zero, length_error   #branch to length error if t2 equal to 0
	bne $t2, $zero, checkString

	#Return error message "input is empty"
	emptyError:
	li $v0, 4
	la $a0, is_empty
	syscall
        j exit
	
	#Return error message "input is too long"
        length_error:
	li $v0, 4
        la $a0, too_large
        syscall
	j exit

	#Checks for characters exceeding base-34 representation
        checkString:
        move $a0, $t5 # Move the user input address from t5 to a0
        
        checkStringLoop:
        li $v0, 11
        lb $t3, 0($a0)
	move $t9, $a0
        move $a0, $t3
        move $a0, $t9
        li $t9, 10       # newline character
	beq $t3, $zero, Initialization   
        slti $t4, $t3, 48               # if char is less than 48 [0] (invalid input)
        bne $t4, $zero, invalid_Base
        slti $t4, $t3, 58               # if char is less than 58 [9] (valid input)
        bne $t4, $zero, Increment
	slti $t4, $t3, 65               # if char is less than 65 [A] (invalid input)
        bne $t4, $zero, invalid_Base  
        slti $t4, $t3, 89               # if char is less than 89 [Y] (valid input)
        bne $t4, $zero, Increment
	slti $t4, $t3, 97               # if char is less than 97 [a] (invalid input)
        bne $t4, $zero, invalid_Base 
        slti $t4, $t3, 121              # if char is less than 121 [y] (valid input)
        bne $t4, $zero, Increment
        bgt $t3, 120, invalid_Base      # if char is greater than 120 [x] (invalid input)
	li $t9, 10                      # Checks if it is a newline character
        beq $t3, $t9, Initialization     
           
        Increment:
	addi $a0, $a0, 1
	j checkStringLoop
	
	#Return error message indicating invalid base-34 number
	invalid_Base:
	li $v0, 4
	la $a0, is_invalid
	syscall
	j exit 

	#conversions are initialized 
	Initialization:   
	move $a0, $t5
        li $t8, 10
        li $t9, 0           #Initialize decimal sum to zero
        add $s0, $s0, $t1
	addi $s0, $s0, -1  #Set appropriate starting power
        li $s7, 3
        li $s6, 2
        li $s5, 1
        li $s1, 0
	
	#Converts valid character to a number
	String_Conversion:     
        lb $s2, 0($a0)
        beqz $s2, display_the_Sum		#End loop if null character is reached
	beq $s2, $t8, display_the_Sum    	#End loop if end-of-line is detected
	slti $t4, $s2, 58                       #Check if the char is less than 58 (0-9)
	bne $t4, $zero, zero_to_nine
        slti $t4, $s2, 89                       #Check if char is less than 89 (A-X)
        bne $t4, $zero, A_to_X
        slti $t4, $s2, 121                      #Check if char is less than 121 (a-x)
        bne $t4, $zero, a_to_x

	zero_to_nine:
	addi $s2, $s2, -48
	j calculations
	
	A_to_X:
	addi $s2, $s2, -55
	j calculations
	
	a_to_x:
	addi $s2, $s2, -87
	
