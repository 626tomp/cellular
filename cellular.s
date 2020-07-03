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

prompt_world_size:	.asciiz "Enter world size: "
error_world_size:	.asciiz "Invalid world size\n"
prompt_rule:		.asciiz "Enter rule: "
error_rule:		.asciiz "Invalid rule\n"
prompt_n_generations:	.asciiz "Enter how many generations: "
error_n_generations:	.asciiz "Invalid number of generations\n"

# Strings for testing purposes
testing_world:	.asciiz "World Size: "
testing_rule:	.asciiz "Rule: "
testing_gen:	.asciiz "Num Generations: "
normalised:		.asciiz "	I Normalised the number of generations"
testing_reverse:.asciiz "Reversed? "

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

	la $a0, prompt_world_size  			# printf("Enter world size: ");
    li $v0, 4
    syscall

	li $v0, 5           				# scanf("%d", input);
    syscall
    move $s0, $v0       				# $s0 = Word Size = x = input

	
	li $t0, MIN_WORLD_SIZE				# Storing MIN_WORLD_SIZE into temp register $t0
	li $t1, MAX_WORLD_SIZE				# Storing MAX_WORLD_SIZE into temp register $t1

										# if (world_size < MIN_WORLD_SIZE || world_size > MAX_WORLD_SIZE)
	blt	$s0, $t0, Invalid_World_Size	# if worldsize( $s0) < MIN_WORLD_SIZE ($t0), goto Invalid_World_Size
	bgt	$s0, $t1, Invalid_World_Size	# if worldsize( $s0) < MAX_WORLD_SIZE ($t1), goto Invalid_World_Size

										# valid world sizes are 1-128 
	b	Valid_World_size				# else goto Valid_World_size

Invalid_World_Size:

	
	la $a0, error_world_size			# printf("Invalid world size");
	li $v0, 4
    syscall

	jr $31 								#return

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

	la $a0, prompt_n_generations  		# printf("Enter Rule: ");
    li $v0, 4
    syscall

	li $v0, 5           				# scanf("%d", input);
    syscall
    move $s2, $v0       				# $s2 = Generation = x = input

	li $t0, MIN_GENERATIONS				# Storing MIN_GENERATIONS into temp register $t0
	li $t1, MAX_GENERATIONS				# Storing MAX_GENERATIONS into temp register $t1

										# if (rule < MIN_GENERATIONS || rule > MAX_GENERATIONS)
	blt	$s2, $t0, Invalid_Rule_Size		# if rule( $s1) < MIN_GENERATIONS ($t0), goto Invalid_Generation_Size
	bgt	$s2, $t1, Invalid_Rule_Size		# if rule( $s1) < MAX_GENERATIONS ($t1), goto Invalid_Generation_Size

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

	li $s3, 0							# reverse = 0
	bge $s2, 0, Skip_Gen_Normalisation	# goto Skip_Gen_Normalisation if positive

	la $a0, normalised					# printf("normalised gens: ");
	li $v0, 4
    syscall

	li $s3, 1							# reverse = 1
	sub $s2, $0, $s2					# n_generations = 0 - n_generations;


Skip_Gen_Normalisation:

## -------------- PRINTING VALUES - FOR TESTING --------

	li   $a0, '\n'     				 	# printf("%c", '\n');
	li   $v0, 11
	syscall

	la $a0, testing_world				# printf("World Size: ");
	li $v0, 4
    syscall

	move $a0, $s0						# printf("%d", World_Size);
	li $v0, 1
    syscall
	
	li   $a0, '\n'      				# printf("%c", '\n');
	li   $v0, 11
	syscall

	la $a0, testing_rule				# printf("Rule: ");
	li $v0, 4
    syscall

	move $a0, $s1						# printf("%d", Rule);
	li $v0, 1
    syscall

	li   $a0, '\n'      				# printf("%c", '\n');
	li   $v0, 11
	syscall

	la $a0, testing_gen					# # printf("Num Generations");
	li $v0, 4
    syscall

	move $a0, $s2						# printf("%d", Num_Generations);
	li $v0, 1
    syscall

	li   $a0, '\n'     				 	# printf("%c", '\n');
	li   $v0, 11
	syscall

	la $a0, testing_reverse				# printf("Num Generations");
	li $v0, 4
    syscall

	move $a0, $s3						# printf("%d", reverse);
	li $v0, 1
    syscall

	li   $a0, '\n'     				 	# printf("%c", '\n');
	li   $v0, 11
	syscall


	# replace the syscall below with
	#
	# li	$v0, 0
	# jr	$ra
	#
	# if your code for `main' preserves $ra by saving it on the
	# stack, and restoring it after calling `print_world' and
	# `run_generation'.  [ there are style marks for this ]

	li	$v0, 10
	syscall



	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `run_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `run_generation' FINISHES
	#

run_generation:

	#
	# REPLACE THIS COMMENT WITH YOUR CODE FOR `run_generation'.
	#

	jr	$ra


	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#

	#
	# REPLACE THIS COMMENT WITH A LIST OF THE REGISTERS USED IN
	# `print_generation', AND THE PURPOSES THEY ARE ARE USED FOR
	#
	# YOU SHOULD ALSO NOTE WHICH REGISTERS DO NOT HAVE THEIR
	# ORIGINAL VALUE WHEN `print_generation' FINISHES
	#

print_generation:

	#
	# REPLACE THIS COMMENT WITH YOUR CODE FOR `print_generation'.
	#

	jr	$ra
