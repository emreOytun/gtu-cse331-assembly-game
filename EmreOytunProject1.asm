.data
	rowInputMessage: .asciiz "Please enter row number (row > 0): "	# The message for row input taking
	colInputMessage: .asciiz "Please enter col number (col > 0): "  # The message for col input taking
	nInputMessage: .asciiz "Please enter number of times (n > 0): " # The message for n input taking
	invalidInputMessage: .asciiz "You entered an invalid input. Try again. \n" # The message for invalid input
	invalidCharInputMessage: .asciiz "\n\nYou entered an invalid character. Enter the initial state from scratch again below: \n" # The message for invalid char input
	newLine: .asciiz "\n" # New line character
	buffer: .space 2 # 1 character for EOF. # Buffer to get inputs

.text
	main:
		# $s0: rowNumber
		# $s1: colNumber
		# $s2: n
		# $s3: character matrix address for game board
		# $s4: integer matrix address for bomb time board
		rowInputWhile:
			# Print rowInputMessage.
			li $v0, 4 # put 4 for print-string syscall
			la $a0, rowInputMessage # put the message into $a0 register for syscall
			syscall # syscall to print message
			
			# Read integer from user for row number.
			# The result is in $v0.
			li $v0, 5 # put 5 for read-word syscall
			syscall # syscall to get word input
			
			bgt $v0, 0, validRowInput # If the input is correct, then go to validInput branch.
			j invalidRowInput # Else, go to invalidInput block.
			
			validRowInput: 	
				move $s0, $v0 # $s0 = $v0 (row number)
				j rowInputWhileExit # The loop is done.
			
			invalidRowInput:
				# Print error message and jump to loop.
				li $v0, 4 # put 4 for print-string syscall
				la $a0, invalidInputMessage # put the message into $a0 register for syscall
				syscall # syscall to print message
				
				j rowInputWhile # Jump to beginning of the loop.
		rowInputWhileExit:
		
		colInputWhile:
			# Print colInputMessage.
			li $v0, 4 # put 4 for print-string syscall
			la $a0, colInputMessage # put the message into $a0 register for syscall
			syscall # syscall to print message
			
			# Read integer from user for col number.
			# The result is in $v0.
			li $v0, 5 # put 5 for read-word syscall
			syscall # syscall to get word input
			
			bgt $v0, 0, validColInput # If the input is correct, then go to validInput branch.
			j invalidColInput # Else, go to invalidInput block.
			
			validColInput: 	
				move $s1, $v0 # $s1 = $v0 (col number)
				
				j colInputWhileExit # The loop is done.
			
			invalidColInput:
				# Print error message and jump to loop.
				li $v0, 4 # put 4 for print-string syscall
				la $a0, invalidInputMessage # put the message into $a0 register for syscall
				syscall # syscall to print message
				
				j colInputWhile # Jump to beginning of the loop.
		colInputWhileExit:
		
		nInputWhile:
			# Print nInputMessage.
			li $v0, 4 # put 4 for print-string syscall
			la $a0, nInputMessage # put the message into $a0 register for syscall
			syscall # syscall to print message
			
			# Read integer from user for n.
			# The result is in $v0.
			li $v0, 5 # put 5 for read-word syscall
			syscall # syscall to get word input
			
			bgt $v0, 0, validNInput # If the input is correct, then go to validInput branch.
			j invalidNInput # Else, go to invalidInput block.
			
			validNInput: 	
				move $s2, $v0 # $s2 = $v0 (n)
				
				j nInputWhileExit # The loop is done.
			
			invalidNInput:
				# Print error message and jump to loop.
				li $v0, 4 # put 4 for print-string syscall
				la $a0, invalidInputMessage # put the message into $a0 register for syscall
				syscall # syscall to print message
				
				j nInputWhile # Jump to beginning of the loop.
		nInputWhileExit:
		
		# Multiply $s0 and $s1 to get the total grids in the matrix.
		# $t0 = number of grids needed for row * col matrix.
		# $t0 = number of bytes needed for row * col character matrix.
		# $t0 = $s0 * $s1 = row * col * 1
		mul $t0, $s0, $s1 # $t0 = total number of grids needed for row * col matrix
		
		# $t1 = number of bytes needed for row * col integer matrix.
		# $t1 = $t0 * 4 = row * col * 4
		mul $t1, $t0, 4 # $t1 = number of bytes needed for row * col integer matrix.
		
		# Allocate $t0(row * col * 1) bytes for character matrix.
		li $v0, 9 # Put 9 for allocate-memory syscall
		move $a0, $t0 # $a0 = calculated memory for character matrix in bytes
		syscall # syscall to allocate memory
		
		move $s3, $v0 # Keep the allocated address for character matrix in $s3 register.
		
		# Allocate $t1(row * col * 4) bytes for integer matrix.
		li $v0, 9 # Put 9 for allocate-memory syscall
		move $a0, $t1 # $a0 = calculated memory for integer time matrix in bytes
		syscall # syscall to allocate memory
		
		move $s4, $v0 # Keep the allocated address for integer matrix in $s4 register.
		
		# Here, the initial state of the matrix is read. 
		# If there is a wrong input, then it starts from scratch to fill the initial state.
		matrixInputMostOuterWhile:
			li $t0, 0 # row index
			matrixInputOuterWhile:
				bge $t0, $s0, matrixInputOuterWhileExit # If the matrix input is taken successfully for all rows, then exit the loop.
				
				li $t1, 0  # reset the col index before starting to iterate on a row
				matrixInputInnerWhile:
					bge $t1, $s1, matrixInputInnerWhileExit # If columns are read successfuly for a row, then exit the inner loop.
					
					# Read char. The input will be in $v0.
					li $v0, 12 # Put 12 for read-char syscall.
					syscall # Syscall to read char
					
					# Check input.
					seq $t2, $v0, 79  # $t0=1 if $v0 is 'O' character (79 in ASCII).
					seq $t3, $v0, 46  # $t0=1 if $v0 is '.' character (46 in ASCII).
					or $t4, $t2, $t3  # $t2 = $t0 | $t1
		
					bgt $t4, 0, validCharInput # If check is successful, go to valid block.
					j invalidCharInput # If check is not successful, go to invalid block.
					validCharInput:
						# Assign the input character to the place in the matrix.
						mul $t5, $t0, $s1 # $t5 = $t0 * $s0 = row index * col number
						add $t5, $t5, $t1 # $t5 = $t5 + $t1 (col index). $t5 is the total bytes for character matrix from start address.
						mul $t6, $t5, 4  # $t6 = $t5 * 4. $t6 is the total bytes for integer matrix from start address.
						
						add $t7, $t5, $s3 # $t7 = the address for the current element in character matrix
						add $t8, $t6, $s4 # $t8 = the address for the current element in integer matrix
						
						sb $v0, ($t7) # v0 is the input character. Save it to the matrix.
						
						# If the input character is O, then set time for here as 0.
						# Otherwise, set time for here as -1.
						bgtz $t2, setBombTimeIf # Check if the input character is 'O'
						j setBombTimeElse # jump to else block
						setBombTimeIf:
							sw $zero, ($t8) # Set 0 if there is bomb.
							j setBombTimeExit # jump to exit
						setBombTimeElse:
							li $t2, -1 # Set -1 if there is no bomb.
							sw $t2, ($t8) # Put -1 into the grid of the time matrix
							j setBombTimeExit # jump to exit
						setBombTimeExit: 
						
						addi $t1, $t1, 1 # Add 1 to the inner loop counter
						j matrixInputInnerWhile # Jump to inner while block
					invalidCharInput:
						# Print error message. Say to try again from scratch.
						li $v0, 4 # put 4 for print-string syscall
						la $a0, invalidCharInputMessage # put the message into $a0 register for syscall
						syscall # syscall to print messages
						
						j matrixInputMostOuterWhile # When char input is invalid, then start to take input for game board from scratch.
				matrixInputInnerWhileExit:
				
				# Print line
				li $v0, 4 # put 4 for print-string syscall
				la $a0, newLine # put the message into $a0 register for syscall
				syscall # syscall to print message
				
				addi $t0, $t0, 1 # Add 1 to the outer loop counter
				j matrixInputOuterWhile # Jump to the outer while
			matrixInputOuterWhileExit:
		matrixInputMostOuterWhileExit:
		
		move $a0, $s0 # $a0 = $s0 = row
		move $a1, $s1 # $a1 = $s1 = col
		move $a2, $s2 # $a2 = $s2 = n
		move $a3, $s3 # $a3 = $s3 = char matrix address
		move $t9, $s4 # $t9 = $s4 = integer matrix address
		jal playGame # jump and link to playGame procedure
			
		# Print line
		li $v0, 4 # put 4 for print-string syscall
		la $a0, newLine # put the message into $a0 register for syscall
		syscall	# syscall to print message
				
		# Print final game board
		move $a0, $s0 # $a0 = $s0 = row
		move $a1, $s1 # $a1 = $s1 = col
		move $a2, $s3 # $a2 = $s2 = char matrix address
		jal printMatrix # jump and link to printMatrix procedure
		
		# Exit the main program.
		li $v0, 10 # Put 10 for exit-program syscall.
		syscall # Syscall to exit program
	
	#################################### FUNCTIONS ##################################
	playGame:
		# Arguments:
		# $a0 = row number
		# $a1 = col number
		# $a2 = n
		# $a3 = game board addrees
		# $t9 = time board address
		
		# Variable to keep in stack:
		# $s0 = $a0 = 4 byte
		# $s1 = $a1 = 4 byte
		# $s2 = $a2 = 4 byte
		# $s3 = $a3 = 4 byte
		# $s4 = $t9 = 4 byte
		# $s5 = loop counter
		# $ra = 4 byte
		# Total = 28 bytes
		addi $sp, $sp, -28 # Move back 20 bytes from stack pointer to store our s registers.
		sw $ra, 0($sp) # Store the $ra register's current value to stack
		sw $s0, 4($sp) # Store the $s0 register's current value to stack
		sw $s1, 8($sp) # Store the $s1 register's current value to stack
		sw $s2, 12($sp) # Store the $s2 register's current value to stack
		sw $s3, 16($sp) # Store the $s3 register's current value to stack
		sw $s4, 20($sp) # Store the $s4 register's current value to stack
		sw $s5, 24($sp) # Store the $s5 register's current value to stack
		
		# Move parameters to s registers since there will be function calls.
		move $s0, $a0 # $s0 = row
		move $s1, $a1 # $s1 = col
		move $s2, $a2 # $s2 = n
		move $s3, $a3 # $s3 = game board address
		move $s4, $t9 # $s4 = time board address
		
		move $a0, $s0 # $a0 = $s0 = row
		move $a1, $s1 # $a1 = $s1 = col
		move $a2, $s4 # $a2 = $s4 = integer matrix address
		jal incrementBombTimes  # Increment bomb times in time board for the 1st second.
		
		li $s5, 2  # $s5 = current time in seconds starting with 2 because 1 second is passed.
		gameLoop:
			bgt $s5, $s2, gameLoopExit # Check if the game is finished. It is finished if time counter > time.
			
			move $a0, $s0 # $a0 = $s0 = row
			move $a1, $s1 # $a1 = $s1 = col
			move $a2, $s4 # $a2 = $s4 = integer matrix address
			jal incrementBombTimes  # Increment bomb times in time board for the second passed.
		
			li $t8, 2 # Load $t8 register with 2 to make division with remainder.
			div $s5, $t8 # Divide current second by 2
			mfhi $t1 # Get remainder from hi register
			beq $t1, 0, callPutBoms # If the remainder is 0, then call putBombsToEmptyGrids. Otherwise, call detonateBombs.
			j callDetonateBombs
			callPutBoms:
				move $a0, $s0 # $a0 = $s0 = row
				move $a1, $s1 # $a1 = $s1 = col
				move $a2, $s3 # $a2 = $s3 = char matrix address
				move $a3, $s4 # $a3 = $s4 = integer matrix address
				jal putBombsToEmptyGrids # jump and link to putBombsToEmptyGrids procedure
				
				j conditionsExit # jump to condition exit
			callDetonateBombs:
				move $a0, $s0 # $a0 = $s0 = row
				move $a1, $s1 # $a1 = $s1 = col
				move $a2, $s3 # $a2 = $s3 = char matrix address
				move $a3, $s4 # $a3 = $s4 = integer matrix address
				jal detonateBombs # jump and link to detonateBombs procedure
			conditionsExit:
			
			addi $s5, $s5, 1 # Increment $t0 for iteration
			j gameLoop # jump back to the gameLoop label
		gameLoopExit:
		
		
		# Load back the stack variables.
		lw $ra, 0($sp) # Load back $ra register's value from stack
		lw $s0, 4($sp) # Load back $s0 register's value from stack
		lw $s1, 8($sp) # Load back $s1 register's value from stack
		lw $s2, 12($sp) # Load back $s2 register's value from stack
		lw $s3, 16($sp) # Load back $s3 register's value from stack
		lw $s4, 20($sp) # Load back $s4 register's value from stack
		lw $s5, 24($sp) # Load back $s5 register's value from stack
		addi $sp, $sp, 28 # Restore the stack pointer since the procedure is done.
		
		jr $ra # jump to the return address.
	
	detonateBombs:
		# Arguments:
		# $a0 = row number
		# $a1 = col number
		# $a2 = game board addrees
		# $a3 = time board address
	
		li $t0, 0 # $t0 is row index, started with 0 before iteration.
		detonateBombsInGameBoardWhile:
			beq $t0, $a0, detonateBombsInGameBoardWhileExit # Check if all rows are iterated. If it is jump to the exit label.
			
			li $t1, 0 # $t1 is col index, started with 0 before iteration.
			detonateBombsInGameBoardInnerWhile:
				beq $t1, $a1, detonateBombsInGameBoardInnerWhileExit # Check if the columns of the current row are iterted. If it is jump to the exit label.
				
				# Calculate the index of the element in the 1D array.
				mul $t2, $t0, $a1 # $t2 = row index * col number
				add $t2, $t2, $t1 # $t2 = $t2 + col index = index in 1D array
				
				# The bytes are equal to index, find the char element's address.
				add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
				
				# Calculate the bytes and the integer element's address.
				mul $t4, $t2, 4   # $t4 = index * element size = how many bytes needed from base address
				add $t5, $a3, $t4 # $t5 = base address + bytes needed = integer element's address
				
				lw $t6, 0($t5) # $t6 = time stored in the time board for the current index
				beq $t6, 3, detonateBomb # If the time is 3, then detonate the bomb. Jump to this block.
				j detonateBombExit # Jump to the condition exit label
				detonateBomb:
					li $t7, 46     # $t7 = '.' character in ASCII
					sb $t7, 0($t3) # Put '.' in place of bomb
					
					bgt $t0, 0, putDotAbove # If the row index is greater than 0, then put '.' above.
					j putDotAboveExit # Jump to the condition exit label
					putDotAbove:
						# Calculate the index of the element in the 1D array.
						add $t8, $t0, -1  # Subtract 1 from row index to go above.
						mul $t2, $t8, $a1 # $t2 = (row index - 1) * col number
						add $t2, $t2, $t1 # $t2 = (row index -1) * colNumber + col index = index in 1D array
					
						# The bytes are equal to index, find the char element's address.
						add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
						sb $t7, 0($t3) # Put '.' to above in game board
					putDotAboveExit:
					
					add $t8, $a0, -1 # Subtract 1 from row number for comparision below.
					blt $t0, $t8, putDotBelow # if (row_index < row_number - 1) put dot below.
					j putDotBelowExit # Jump to the condition exit label
					putDotBelow:
						# Calculate the index of the element in the 1D array.
						add $t8, $t0, 1  # Add 1 to row index to go below.
						mul $t2, $t8, $a1 # $t2 = (row index + 1) * col number
						add $t2, $t2, $t1 # $t2 = (row index + 1) * colNumber + col index = index in 1D array
					
						# The bytes are equal to index, find the char element's address.
						add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
						sb $t7, 0($t3) # Put '.' to below in game board
					putDotBelowExit:
					
					bgt $t1, 0, putDotLeft # if (col_index > 0), then put dot to left.
					j putDotLeftExit # Jump to the condition exit label
					putDotLeft:
						# Calculate the index of the element in the 1D array.
						addi $t8, $t1, -1 # $t8 = col index - 1
						mul $t2, $t0, $a1 # $t2 = row index * col number
						add $t2, $t2, $t8 # $t2 = row index * col number + (col index - 1) = index in 1D array
					
						# The bytes are equal to index, find the char element's address.
						add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
						sb $t7, 0($t3) # Put '.' to left in game board
					putDotLeftExit:
					
					add $t8, $a1, -1 # Subtract 1 from col number for comparision below.
					blt $t1, $t8, putDotRight # if (col_index < col_number - 1) put dot to right.
					j putDotRightExit # Jump to the condition exit label
					putDotRight:
						# Calculate the index of the element in the 1D array.
						add $t8, $t1, 1  # Add 1 to col index to go right.
						mul $t2, $t0, $a1 # $t2 = row index * col number
						add $t2, $t2, $t8 # $t2 = row index * colNumber + (col index + 1) = index in 1D array
					
						# The bytes are equal to index, find the char element's address.
						add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
						sb $t7, 0($t3) # Put '.' to right in game board
					putDotRightExit:
				detonateBombExit:
				
				addi $t1, $t1, 1 # Increment col index
				j detonateBombsInGameBoardInnerWhile # Jump back to the inner while.
			detonateBombsInGameBoardInnerWhileExit:
			
			addi $t0, $t0, 1 # Increment row index
			j detonateBombsInGameBoardWhile # Jump back to the outer while
		 detonateBombsInGameBoardWhileExit: 
	
		li $t0, 0 # $t0 is row index, started with 0 before iteration.
		clearBombsInBombTableWhile:
			beq $t0, $a0, clearBombsInBombTableWhileExit #If rows are completed, then iteration is done.
			
			li $t1, 0 # $t1 is col index, started with 0 before iteration.
			clearBombsInBombTableInnerWhile:
				beq $t1, $a1, clearBombsInBombTableInnerWhileExit # If col is completed, then iteration on a row is done.
				
				# Calculate the index of the element in the 1D array.
				mul $t2, $t0, $a1 # $t2 = row index * col number
				add $t2, $t2, $t1 # $t2 = $t2 + col index = index in 1D array
				
				# The bytes are equal to index, find the char element's address.
				add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
				
				# Calculate the bytes and the integer element's address.
				mul $t4, $t2, 4   # $t4 = index * element size = how many bytes needed from base address
				add $t5, $a3, $t4 # $t5 = base address + bytes needed = integer element's address
				
				lb $t6, 0($t3) # Load character from game board
				li $t7, 46     # $t7 = '.' in ASCII
				beq $t6, $t7, clearBombTime # If current element is '.', then clear time table for this.
				j clearBombTimeExit
				clearBombTime:
					li $t7, -1 # Load -1 to $t7 for the purpose of storing -1 into memory
					sw $t7, 0($t5) # $t7(current element in time board) = -1 
				clearBombTimeExit:
				
				addi $t1, $t1, 1 # Increment col index
				j clearBombsInBombTableInnerWhile # Jump back to the inner while
			clearBombsInBombTableInnerWhileExit:
			
			addi $t0, $t0, 1 # Increment row index
			j clearBombsInBombTableWhile # Jump back to the outer while
		 clearBombsInBombTableWhileExit: 
		
		jr $ra # Jump to the caller address
		
		
	
	putBombsToEmptyGrids:
		# Arguments:
		# $a0 = row number
		# $a1 = col number
		# $a2 = game board address
		# $a3 = time board address
	
		li $t0, 0 # $t0 is row index, started with 0 before iteration.
		putBombOuterWhile:
			beq $t0, $a0, putBombOuterWhileExit # Check if all rows are iterated
			
			li $t1, 0 # $t1 is col index, started with 0 before iteration.
			putBombInnerWhile:
				beq $t1, $a1, putBombInnerWhileExit # Check if the columns of the current row are iterated
				
				# Calculate the index of the element in the 1D array.
				mul $t2, $t0, $a1 # $t2 = row index * col number
				add $t2, $t2, $t1 # $t2 = $t2 + col index = index in 1D array
				
				# The bytes are equal to index, find the char element's address.
				add $t3, $a2, $t2 # $t3 = game board base address + bytes needed = char element address
				
				# Calculate the bytes and the integer element's address.
				mul $t4, $t2, 4   # $t4 = index * element size = how many bytes needed from base address
				add $t5, $a3, $t4 # $t5 = base address + bytes needed = integer element's address
				
				lw $t6, 0($t5) # $t6 = time stored in the time board for the current index
				beq $t6, -1, putBomb # If the time is not -1, then jump to increment block.  
				j putBombExit
				putBomb:
					li $t7, 79 # $t7 = 'O' character's ASCII value 79 
					sb $t7, 0($t3) # Store 'O' character's ASCII value to the gameBoard
					
					sw $zero, 0($t5) # Store '0' value to the time board
					
					j putBombExit # Jump to the condition exit label
				putBombExit:
				
				addi $t1, $t1, 1 # Increment col index
				j putBombInnerWhile # Jump back to the inner while
			putBombInnerWhileExit:
			
			addi $t0, $t0, 1 # Increment row index
			j putBombOuterWhile # Jump back to the outer while
		 putBombOuterWhileExit: 
	
		jr $ra # Jump to the caller address
	
	incrementBombTimes:
		# Arguments:
		# $a0 = row number
		# $a1 = col number
		# $a2 = time board matrix address
	
		li $t0, 0 # $t0 is row index, started with 0 before iteration.
		incrementBombTimeOuterWhile:
			beq $t0, $a0, incrementBombTimeOuterWhileExit # Check if all rows are iterated.
			
			li $t1, 0 # $t1 is col index, started with 0 before iteration.
			incrementBombTimeInnerWhile:
				beq $t1, $a1, incrementBombTimeInnerWhileExit # Check if all columns of the current row are iterated.
				
				# Calculate the index of the element in the 1D array.
				mul $t2, $t0, $a1 # $t2 = row index * col number
				add $t2, $t2, $t1 # $t2 = $t2 + col index = index in 1D array
				
				# Calculate the bytes and the element's address.
				mul $t2, $t2, 4   # $t2 = index * element size = how many bytes needed from base address
				add $t3, $a2, $t2 # $t3 = base address + bytes needed = element's address
				
				lw $t4, 0($t3) # $t4 = time stored in the time board
				bne $t4, -1, increment # If the time is not -1, then jump to increment block.  
				j incrementCheckExit
				increment:	# Increment the time.
					addi $t4, $t4, 1  # Add 1 to the time
					sw $t4, 0($t3)    # Store the incremented time
					j incrementCheckExit # Jump to condition exit label
				incrementCheckExit:
				
				addi $t1, $t1, 1 # Increment col index
				j incrementBombTimeInnerWhile # Jump to inner while
			incrementBombTimeInnerWhileExit:
			
			addi $t0, $t0, 1 # Increment row index
			j incrementBombTimeOuterWhile # Jump back to the outer while
		 incrementBombTimeOuterWhileExit: 
	
		jr $ra # Jump to the caller address
	
	printMatrix:
		# Arguments:
		# $a0 = row number
		# $a1 = col number
		# $a2 = matrix address
	
		# Move the current stack to keep stack values for the s register values that this function uses.
		# S registers that this function uses:
		# $ra = return address = 4 byte 
		# $s0 = $v0 = row = 4 byte
		# $s1 =  $v1 = col = 4 byte
		# $s2 = $v2 = char matrix address = 4 byte
		# Total bytes = 16 bytes
		addi $sp, $sp, -16  # Move back 20 bytes from stack pointer to store s registers.
		sw $ra, 0($sp) # Store the $ra register's current value to stack
		sw $s0, 4($sp) # Store the $s0 register's current value to stack
		sw $s1, 8($sp) # Store the $s1 register's current value to stack
		sw $s2, 12($sp) # Store the $s2 register's current value to stack
		
		# Move the argument to the s registers because there will be at least syscalls so there is no confusion.
		move $s0, $a0 # $s0 = row number
		move $s1, $a1 # $s1 = col number
		move $s2, $a2 # $s2 = matrix address
		
		# $t0 and $t1 are indexes.
		li $t0, 0 # $t0 = row index
		li $t1, 0 # $t1 = col index
		printMatrixRowWhile:
			bge $t0, $s0, printMatrixRowWhileExit # Check if all rows are printed.
			
			li $t1, 0 # Set col index to 0 before iterating on a row.
			printMatrixColWhile:
				bge $t1, $s1, printMatrixColWhileExit # Check if all columns of the row are printed.
				
				mul $t2, $t0, $s1 # $t2 = row index * col number
				add $t3, $t2, $t1 # $t3 = $t2 + $t1 (col index) = total bytes from starting base address.
				add $t4, $s2, $t3 # $t4 = $s2 + $t3 = total bytes from start address + start address = required address
				
				# Print character.
				li $v0, 11 # Put 11 to $a0 for print-byte syscall.
				lb $a0, ($t4) # $a0 = The character in the matrix 
				syscall # Syscall for print-byte
				
				addi $t1, $t1, 1  # Add 1 to the col index $t1
				j printMatrixColWhile # Jump to the start of inner while.
			printMatrixColWhileExit:
			
			# Print new line
			li $v0, 4 # put 4 for print-string syscall
			la $a0, newLine # put the message into $a0 register for syscall
			syscall # syscall to print message
			
			
			addi $t0, $t0, 1  # Add 1 to the row index $t0
			j printMatrixRowWhile # Jump to the start of outer while.
		printMatrixRowWhileExit:
		
		# Put back the restored stack values.
		lw $ra, 0($sp) # Load back $ra register's value from stack
		lw $s0, 4($sp) # Load back $s0 register's value from stack
		lw $s1, 8($sp) # Load back $s1 register's value from stack
		lw $s2, 12($sp) # Load back $s2 register's value from stack
		addi $sp, $sp, 16 # Restore the stack pointer since the procedure is done.
		
		jr $ra	# Return back to the caller.
