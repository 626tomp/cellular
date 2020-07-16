########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by Thomas Parish: z5207264, July 2020.


# Maximum and minimum values for the 3 parameters.

MIN_WORLD_SIZE	=    1
MAX_WORLD_SIZE	=  128
MIN_GENERATIONS	= -256
MAX_GENERATIONS	=  256
MIN_RULE	=    0
MAX_RULE	=  255

# Characters used to print alive/dead cells.

ALIVE_CHAR	= '#'
DEAD_CHAR	= '.'

# Maximum number of bytes needs to store all generations of cells.

MAX_CELLS_BYTES	= (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE

	.data

# `cells' is used to store successive generations.  Each byte will be 1
# if the cell is alive in that generation, and 0 otherwise.

cells:	.space MAX_CELLS_BYTES


# Some strings you'll need to use:

prompt_world_size:      .asciiz "Enter world size: "
error_world_size:       .asciiz "Invalid world size\n"
prompt_rule:            .asciiz "Enter rule: "
error_rule:             .asciiz "Invalid rule\n"
prompt_n_generations:   .asciiz "Enter how many generations: "
error_n_generations:    .asciiz "Invalid number of generations\n"

# Strings for testing purposes
testing_world:	        .asciiz "World Size: "
testing_rule:	        .asciiz "Rule: "
testing_gen:	        .asciiz "Num Generations: "
normalised:		        .asciiz "	I Normalised the number of generations"
testing_reverse:        .asciiz "Reversed? "
testing_gen_func:       .asciiz "Made it to generate function. "
testing_print_func:     .asciiz "Made it to print function. "
testing_main_func:      .asciiz "Made it back to the main function OK! "
address_r:              .asciiz " Address at right: "
address_s:              .asciiz " Address at start: "
address_c:              .asciiz " Address at centre: "
address_l:              .asciiz " Address at left: "

	.text

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `main', AND THE PURPOSES THEY ARE ARE USED FOR
	# 
	#	Register $s0 contains the World Size	
	#	Register $s1 contains the Rule	
	#	Register $s2 contains the Number of Generations	
	#	Register $s3 contains the Reverse boolean
	#
	#	Temporary Registers' uses will be described when they are being used
	# 		- Generally however
	#				- $t0 is used for minimum values
	#				- $t1 is used for maximum values
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

main:
	#
	# REPLACE THIS COMMENT WITH YOUR CODE FOR `main'.
	#

# line 109 in c implementation
## -------------- GETTING WORLD SIZE--------------------
# temp registers used:
#	- $t0 used for min world size
#	- $t1 used for max world size

    la $a0, prompt_world_size           # printf("Enter world size: ");
    li $v0, 4
    syscall

    li $v0, 5                           # scanf("%d", input);
    syscall
    move $s0, $v0                       # $s0 = Word Size = x = input


    li $t0, MIN_WORLD_SIZE              # Storing MIN_WORLD_SIZE into temp register $t0
    li $t1, MAX_WORLD_SIZE              # Storing MAX_WORLD_SIZE into temp register $t1

                                        # if (world_size < MIN_WORLD_SIZE || world_size > MAX_WORLD_SIZE)
    blt	$s0, $t0, Invalid_World_Size    # if worldsize( $s0) < MIN_WORLD_SIZE ($t0), goto Invalid_World_Size
    bgt	$s0, $t1, Invalid_World_Size    # if worldsize( $s0) < MAX_WORLD_SIZE ($t1), goto Invalid_World_Size

                                        # valid world sizes are 1-128 
    b	Valid_World_size                # else goto Valid_World_size

Invalid_World_Size:

    la $a0, error_world_size            # printf("Invalid world size");
    li $v0, 4
    syscall

    jr $31                              #return

Valid_World_size:

# line 117 in c implementation
## -------------- GETTING RULE -------------------------
# temp registers used:
#	- $t0 used for min rule
#	- $t1 used for max rule

    la $a0, prompt_rule  				# printf("Enter Rule: ");
    li $v0, 4
    syscall

    li $v0, 5           				# scanf("%d", input);
    syscall
    move $s1, $v0       				# $s1 = Rule = x = input

    li $t0, MIN_RULE					# Storing MIN_RULE into temp register $t0
    li $t1, MAX_RULE					# Storing MAX_RULE into temp register $t1

                                        # if (rule < MIN_RULE || rule > MAX_RULE)
    blt	$s1, $t0, Invalid_Rule_Size		# if rule( $s1) < MIN_RULE ($t0), goto Invalid_Rule_Size
    bgt	$s1, $t1, Invalid_Rule_Size		# if rule( $s1) < MAX_RULE ($t1), goto Invalid_Rule_Size

                                        # valid rule sizes are 0-255
    b	Valid_Rule_Size					# else goto Valid_Rule_Size

Invalid_Rule_Size:

    la $a0, error_rule					# printf("Invalid rule size");
    li $v0, 4
    syscall

    jr $31 								# return

Valid_Rule_Size:

# line 125 in c implementation
## -------------- GETTING NUMBER OF GENERATIONS --------
# temp registers used:
#	- $t0 used for min generations
#	- $t1 used for max generations
#	- $s3 contains the Reverse boolean

    la $a0, prompt_n_generations  		# printf("Enter Rule: ");
    li $v0, 4
    syscall

    li $v0, 5           				# scanf("%d", input);
    syscall
    move $s2, $v0       				# $s2 = Generation = x = input

    li $t0, MIN_GENERATIONS				# Storing MIN_GENERATIONS into temp register $t0
    li $t1, MAX_GENERATIONS				# Storing MAX_GENERATIONS into temp register $t1

                                        # if (rule < MIN_GENERATIONS || rule > MAX_GENERATIONS)
    blt	$s2, $t0, Invalid_Generation_Size # if rule( $s1) < MIN_GENERATIONS ($t0), goto Invalid_Generation_Size
    bgt	$s2, $t1, Invalid_Generation_Size # if rule( $s1) < MAX_GENERATIONS ($t1), goto Invalid_Generation_Size

                                        # valid rule sizes are -256 to 256
    b	Valid_Generation_Size					# else goto Valid_Generation_Size

Invalid_Generation_Size:

    la $a0, error_n_generations			# printf("InvaInvalid number of generationslid rule size");
    li $v0, 4
    syscall

    jr $31 								# return

Valid_Generation_Size:


# line 135 in c implementation
## -------------- NORMALISING GENERATION NUMBER --------

    li  $s3, 0							# reverse = 0
    bge $s2, 0, Skip_Gen_Normalisation	# goto Skip_Gen_Normalisation if positive

    li  $s3, 1							# reverse = 1
    sub $s2, $0, $s2					# n_generations = 0 - n_generations;


Skip_Gen_Normalisation:

    li $a0, '\n'
    li $v0, 11
    syscall

## -------------- CALLING RUN_GENERATION ---------------
# registers used:
#	- $a1 used for world_size
#	- $a0 used for which_generation
#   - $a2 used for rule
#   - $s4 is the counter

    sub $sp, $sp, 4                    # move stack pointer down to make room
    sw  $ra, 0($sp)                    # save $ra on $stack

    la  $t2, cells                      # loads the address of the start of the array into $t2                
    div $t4, $s0, 2                     # calculates the index offest of the middle bit. world size / 2
    add $t5, $t2, $t4                   # adds the offset to the memory address of the start

    li  $t6, 1
    sb  $t6, ($t5)                      # sets the memory at t5 to be 1
                                        # this is setting the middle bit of the first row 
                                        # of the array to be 1
                                        

    li $s4, 1                           # int i = 1

main_loop_generate:

    bgt $s4, $s2, main_loop_generate_end    # if ( i >= num_generations); goto end;
    
    move $a0, $s4                       # passing which generation into the function
    move $a1, $s0                       # passing in world size
    move $a2, $s1                       # passing in the rule

    jal  run_generation                 # set $ra to following address
                                        # ie calls the function 'run_generation'

    add $s4, $s4, 1                     # i++
    b   main_loop_generate

main_loop_generate_end:
    
    

## -------------- CALLING PRINT_GENERATION -------------
# registers used:
#	- $a0 used for world_size
#	- $a1 used for which_generation
#	- $s4 used to loop through the array
    
    beq $s3, 1, reverse
    li  $s4, 0                          # sets the counter variable to 0 (i = 0)
    b main_loop_print_forwards
reverse:
    move $s4, $s2                       # sets the counter variable to num_generations (i = num_generations)
    b	main_loop_print_backwards
    
main_loop_print_forwards:

    bgt  $s4, $s2,  main_loop_print_end
    move $a0, $s0                       # loads world size into the function
    move $a1, $s4                       # loads counter variable into function
    jal  print_generation               # set $ra to following address
                                        # ie calls the function 'print_generation'

    add $s4, $s4, 1                     # i++
    b   main_loop_print_forwards

main_loop_print_backwards:
    blt $s4, 0, main_loop_print_end

    move $a0, $s0                       # loads world size into the function
    move $a1, $s4                       # loads counter variable into function
    jal  print_generation               # set $ra to following address
                                        # ie calls the function 'print_generation'

    sub $s4, $s4, 1                     # i--
    b   main_loop_print_backwards

main_loop_print_end:

## -------------- ENDING MAIN --------------------------

    lw   $ra, 0($sp)                    # recover $ra from $stack
    add  $sp, $sp, 4                    # move stack pointer back to what it was

	li	$v0, 0
	jr	$ra
	#
	# if your code for `main' preserves $ra by saving it on the
	# stack, and restoring it after calling `print_world' and
	# `run_generation'.  [ there are style marks for this ]




	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

run_generation:
# registers used:
#	- Register $s0 contains the World Size	
#	- Register $s1 contains the Rule
#   - Register $s2 is used to store which generation it is from $a0
#   - Register $s3 is used to count through the array
#	- Register $s4 is the address of the start of the array we are up to
#   - Register $s6 is used to store the variable state
#   - Register $s7 is used to store the boolean set
#	- $t2 stores the variable centre
#	- $t3 stores the variable left
#	- $t4 stores the variable right
#	- $t5 stores the variable bit

        # Registers with different values:
            #t1-6,8, $a0, $s6,7
        # Registers with their values restored
            # $s0-4

    addi $sp, $sp, -20                  # making room to store on the stack
    sw $s0, 0($sp)                      # storing registers s0-s3 onto the stack
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)

    move $s2, $a0                       # saving the generation number
    move $s0, $a1                       # saving the  world size
    move $s1, $a2                       # saving the rule

    la   $s4, cells                     # stores the address for the array in t3 11

    mul  $t2, $s0, 1                    # figures out how big each generation is
    mul $t3, $t2, $s2                   # figures out how many generations we need to go into memory
    add $s4, $s4, $t3                   # finds the address of the first value in the current generation

    li $s3, 0                           # i = 0;

run_generation_loop: 

    bge $s3, $s0, run_generation_loop_end   # if (i >= world_size) goto end;
    
    # li   $a0, DEAD_CHAR     				 	
	# li   $v0, 11
	# syscall
## ---------- CALCULATING LEFT, CENTRE, RIGHT ----------

    beqz $s3, skip_left_side                 # if x = 0, goto left_side: (ie skip a bit)


                                        # left = cells[which_generation - 1][x - 1];
    mul $t3, $s0, 1                     # size of one generation in the array
    sub $t2, $s4, $t3                   # array[i-1]
    sub $t2, $t2, 1                     # array[i-1][x-1]

    lb $t6, ($t2)                       # left = array[i-1][x-1]
    b right_side
    
skip_left_side:

    li $t6, 0

right_side:

    sub $t4, $s0, 1                     # if (x >= wordl_size - 1)
    bge $s3, $t4, skip_right_side             # goto right_side: (ie skip a bit)

                                        # right = cells[which_generation - 1][x + 1];
    mul $t3, $s0, 1                     # size of one generation in the array
    sub $t2, $s4, $t3                   # array[i-1]
    add $t2, $t2, 1                     # array[i-1][x+1]
    
    lb $t4, ($t2)                      # right = array[i-1][x+1]
    b centre
    
skip_right_side:

    li $t4, 0

centre:

                                        # int centre = cells[which_generation - 1][x];
    mul $t3, $s0, 1                     # size of one generation in the array
    sub $t2, $s4, $t3                   # centre = array[i-1][x]

    lb $t2 ($t2)

## ---------- CALCULATING STATE, BIT AND SET -----------
    
    move $t3, $t6

    sllv $t3, $t3, 2                    # left << 2
    sllv $t2, $t2, 1                    # centre << 1
    sllv $t4, $t4, 0                    # right << 0
    # STATE = $s6

    li $s6, 0                           # state = 0
    or $s6, $s6, $t3                    # state = state | left
    or $s6, $s6, $t2                    # state = state | centre
    or $s6, $s6, $t4                    # state = state | right

    li $t5, 1                           # bit = 1
    sllv $t5, $t5, $s6                  # int bit = 1 << state

    and $s7, $t5, $s1                   # int set = rule & bit;

    beqz $s7, generate_cell_dead        # if (set) goto cell alive, else goto cell dead

generate_cell_alive:

    li $t8, 1
    sb $t8, ($s4)                       # array[x][i] = 1
    b end_generate_cell

generate_cell_dead:

    li $t8, 0
    sb $t8, ($s4)                       # array[x][i] = 0
    b end_generate_cell

end_generate_cell:


    add $s3, $s3, 1                     # i++
    add $s4, $s4, 1                     # moves onto the next array index
    b run_generation_loop               # goto loop start

run_generation_loop_end:

    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    lw  $s2, 8($sp)
    lw  $s3, 12($sp)                    
    lw  $s4, 16($sp)                    # recover s0-s3 from $stack
    addi  $sp, $sp, 20                  # move stack pointer back to what it was

	jr	$ra


	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#

print_generation:
# registers used:
#	- $s0 used for world_size which is moved from $a0
#	- $s1 used for which_generation which is moved into $a1
#   - $s2 is used for the loop counter
#   - $s3 holds the value for the current index in the array (ie whether its alive or dead)
#   - $t3 holds the address for the 2d cells array
#   - $s4 holds the current index we care about

        # Registers with different values:
            #t3,5,6, $a0
        # Registers with their values restored:
            # $s0-4

    addi $sp, $sp, -20                  # making room to store on the stack
    sw $s0, 0($sp)                      # storing registers s0-s4 onto the stack
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)

## -------------- SETTING UP ADDRESSES TO PRINT---------

                                        # saving the function parameters into registers we can use
    move $s0, $a0                       # saving world size
    move $s1, $a1                       # saving which generation
    
    move  $a0, $s1    				 	# printf("%d", which_generation);
    li   $v0, 1
    syscall

    li   $a0, '\t'     				 	# putchar('\t');
    li   $v0, 11
    syscall

    li  $s2, 0                          # x = 0

    la   $t3, cells                     # stores the address for the array in t3
    mul  $t5, $s0, 1                    # figures out how big each generation is
    mul $t6, $t5, $s1                   # figures out how many generations we need to go into memory
    add $s4, $t3, $t6                   # finds the address of the first value in the current generation

## -------------- LOOPING THROUGH ARRAY-----------------

print_loop:

        bge $s2, $s0, print_loop_end    # for (int x = 0; x < world_size; x++)

        lb   $s3, ($s4)                 # loads current array index into $s4
        beqz $s3, print_cell_dead       # if (cells[which_generation][x] == 0) goto print_cell_dead
        b   print_cell_alive            # else goto print_cell_alive
        
print_cell_alive:
        li   $a0, ALIVE_CHAR            # printf("%c", '#');
        li   $v0, 11
        syscall
        
        b done_print                    # goto b done_print

print_cell_dead:
        li   $a0, DEAD_CHAR             # printf("%c", '.');
        li   $v0, 11
        syscall

        b done_print                    # goto b done_print

done_print:
        
        
        add $s4, $s4, 1                 # increments the array index
        add $s2, $s2, 1                 # x++
        b   print_loop                  # goto print_loop:
    
print_loop_end:

    li   $a0, '\n'     				 	# putchar('\n');
    li   $v0, 11
    syscall

    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    lw  $s2, 8($sp)
    lw  $s3, 12($sp)                     
    lw  $s4, 16($sp)                    # recover s0-s3 from $stack
    addi  $sp, $sp, 20                  # move stack pointer back to what it was

	jr	$ra
