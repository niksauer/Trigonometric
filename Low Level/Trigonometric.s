#
#   Trigonometric.s
#   Trigonometric
#
#   Created by Niklas Sauer on 14.05.17.
#   Copyright © 2017 DHBW Stuttgart. All rights reserved.
#

.data
    pi:                     .double     3.141592653589793238462643383279502884197169399375105820974
    pi_half:                .double     1.570796326794896619231321691639751442098584699687552910487
    approximations:         .word       6

    welcomeMessage:         .asciiz     "Tabulates trigonometric function results for n equidistant values in user specified interval [x(min), x(max)].\n"
    partitionsQuestion:     .asciiz     "Please input the desired number (n) of equidistant values: "
    xMinQuestion:           .asciiz     "Please specify the interval start [x(min)]: "
    xMaxQuestion:           .asciiz     "Please specify the interval end [x(max)]: "

    NaNErrorMessage:        .asciiz     "ERROR - Undefined result (NaN)."
    intervalErrorMessage:   .asciiz     "ERROR - Interval end [x(max)] must be larger than interval start [x(min)].\n"

    tableHeader:            .asciiz     " x\t| sin(x)\t\t\t| cos(x)\t\t\t| tan(x)\n"
    columnSeperator:        .asciiz     "\t|"
    rowSeperator:           .asciiz     "-----------------------------------------------------------------------------------------------\n"
    lineBreak:              .asciiz     "\n"


.text
.globl main
    main:
        # Display greeting
        la $a0, welcomeMessage        # Load string
        li $v0, 4               # Define output
        syscall                 # .

        # Get Interval min
        la $a0, xMinQuestion     # Ask for x min
        li $v0, 4               # Define output
        syscall                 # .
        li $v0, 7               # Define input
        syscall                 # Get x min
        mov.d $f20, $f0			# store in f20

        # Get x max
        la $a0, xMaxQuestion     # Ask for x max
        li $v0, 4               # Define output
        syscall                 # .
        li $v0, 7               # Define input
        syscall					# Get x max
        mov.d $f22, $f0			# store in f20

        # Validate Intervall
        c.lt.d $f20, $f22		# x min < x max
        bc1f intervall_error    # otherwise, error and ask again

        # Get Number of steps = n
        la $a0, partitionsQuestion        # Ask for n
        li $v0, 4               # Define output
        syscall                 # .
        li $v0, 7               # Define input
        syscall                 # Get n
        mov.d $f24, $f0			# Store n in f24

        # User input done, calculate the steps between x min and max
        sub.d $f22, $f22, $f20	# Calculate difference and store in f22
        div.d $f26, $f22, $f24	# Divide difference by n = stepsize, store in f26

        # Stepsize calculated, in f26

        # Print legend for Table output
        la $a0, tableHeader            # Load asciiz
        li $v0, 4               # Define output
        syscall                 # Print
        la $a0, rowSeperator          # Load seperator asciiz
        syscall                 # Print

        li.d $f28, 0.0          # Initialize counter for loop

    calc_loop:
        # Calculation loop:
        # n -> f24
        # counter -> f28
        # Print next set of x, sin(x), cos(x) and tan(x) in table

        # Exit Condition: If n is <= counter, exit
        c.le.d $f24, $f28       # n <= counter?
        bc1t end                # Then, program has finished

        # Otherwise, print next row

        # Print x
        mov.d $f12, $f20		# Load x as argument
        li $v0, 3               # Define double output
        syscall                 # Print
        jal print_pipe          # Seperate columns

        # Get sin(x)
        jal sin                 # Execute sin(x) (x is still in f12)
        mov.d $f30, $f0			# Store output in f30 for tan later

        # Print sin(x)
        mov.d $f12, $f0         # Load output as argument
        li $v0, 3               # Define double output
        syscall                 # Print
        jal print_pipe          # Seperate columns

        # Get cos(x)
        mov.d $f12, $f20		# Load x as argument
        jal cos                 # Execute cos(x)

        # Print cos(x)
        mov.d $f12, $f0         # Load output as arument
        li $v0, 3               # Define double output
        syscall                 # Print
        jal print_pipe          # Seperate columns

        # Get tan(x)
        mov.d $f12, $f30        # Load sin(x) as argument
        mov.d $f14, $f0         # Load cos(x) as argument
        jal tan                 # Execute tan(x)

        # Print tan(x)
        # Preparation for print happens in tan
        syscall                 # Print

        # Done with row, print a new line & seperator
        la $a0, lineBreak         # Load \n
        li $v0, 4               # Define output
        syscall                 # Print
        la $a0, rowSeperator          # Load seperator
        li $v0, 4               # Define output
        syscall                 # Print

        # Move on with intervall
        add.d $f20, $f20, $f26	# new x is x min + stepsize

        # Increment counter
        li.d $f4, 1.0           # Load 1
        add.d $f28, $f28, $f4	# Increment counter by 1

        j calc_loop             # Next iteration

    sin:
        # Calculate sin(x)

        # Store return adress
        addi $sp, $sp, -4		# Make space
        sw $ra, 0($sp)			# Store return adress

        ### Algorithm, see c program

        # Prepare Flag
        li $a0, 1

        # Map negative values of x into positive
        li.d $f4, 0.0           # Load 0 for comparison
        c.lt.d $f12, $f4        # If x is negative
        bc1t invert             # Make it poitive!

        # Cntinue with mapping
        jal mapLoop

        # Restore return adress
        lw $ra, 0($sp)			# Load return adress
        addi $sp, $sp, 4		# Free space
        jr $ra                  # Go back

    invert:
        # Map a negative value x1 to a positive one x2
        # where sin(x1) = flag * sin(x2)

        # Invert
        li.d $f4, -1.0          # Load -1
        mul.d $f12, $f12, $f4   # Multiply x with -1

        # Adjust position
        ldc1 $f4, pi			# load pi in f4
        add.d $f12, $f12, $f4   # Add Pi

        # Flag adjustment
        li $a0, 1               # Set flag for loop

        # Mapping algorithm
        j mapLoop

    mapLoop:
        # Map everything to the [-pi/2, pi/2] intervall
        # By substracting pi

        # Check if we are done
        ldc1 $f4, pi_half       # load pi/2 in f4
        c.le.d $f12, $f4        # If x is in bounds
        bc1t sin0               # Jump out of loop if true

        # Else: Mapping loop
        ldc1 $f4, pi            # Load pi
        sub.d $f12, $f12, $f4   # Subtract: x = x - pi
        li, $t0, -1             # Load -1
        mul $a0, $a0, $t0       # Invert flag

        j mapLoop               # Loop

    sin0:
        # After mapping, calculate sin0(x)
        # x: f12
        # flag: a0, ->s2
        # result: f24
        # term: f20
        # term2: f22
        # counter: s0

        # Save return adress
        addi $sp, $sp, -48		# Make space
        sw $ra, 0($sp)			# Store return adress

        # save registers to be used
        sw $s0, 4($sp)			# to save counter variable
        sw $s1, 8($sp)          # to save iteration count
        sw $s2, 12($sp)         # to save result from last method (flag)
        sdc1 $f20, 16($sp)      # to save term

        #not needed?: sdc1 $f22, 24($sp)      # to save term2
        sdc1 $f24, 24($sp)      # to save overall result
        sdc1 $f26, 32($sp)      # to save power result
        sdc1 $f28, 40($sp)      # to store counter (as double)

        move $s2, $a0           # capture the flag!
        li $s0, 1               # set s0 to 1 for the counter variable
        lw $s1, approximations      # set s1 to the iteration count

        mov.d $f20, $f12        # set term (f20) to x
        mov.d $f24, $f12        # set result (f24) to x

        # Prepare for loop, calculate constants
        li.d $f14, 2.0          # set 2nd arg
        jal power               # calculate power
        mov.d $f26, $f0         # save result of power operation

    sin0Loop:
        # Loop for sin() calculation
        # term: f20
        # term2: f22
        # counter: s0

        # Exit condition for loop
        bge $s0, $s1, sin0_end	# If counter is larger than desired iterations, youre done

        mtc1.d $s0, $f28		# Synchronize counter with counter in cop. 1
        cvt.d.w $f28, $f28		# Convert counter to double

        li.d $f4, 2.0			# Load 2 in temp. reg. for term 2*i
        mul.d $f16, $f28, $f4	# 2*i is now in f16

        li.d $f6, 1.0			# Load 1 in temp. reg. for term 2*i+1
        add.d $f18, $f16, $f6	# 2*i+1 is now in f18

        mul.d $f4, $f16, $f18	# (2*i+1)*2*i is now in f4

        # Divide pow(x,2) by f4
        div.d $f16, $f26, $f4	# pow(x,2) is in f26, divide by f4 and store in f16

        # Complete term2
        mul.d $f20, $f20, $f16	# multiply term (which is in f20) with (x^2)/(4i^2 + 2i) which is in f16

        # Calculate pow(-1, counter)
        li.d $f12, -1.0			# Prepare 1st arg for power
        mov.d $f14, $f28		# Prepare 2nd arg for power, the counter
        jal power				# Calculate power

        # Multiply the result with the term2
        mul.d $f0, $f0, $f20	# result is in f0, term2 in f20
        add.d $f24, $f24, $f0	# save to overall result
        addi $s0, $s0, 1		# increment counter
        j sin0Loop              # Loop

    sin0_end:
        # Almost finished, restore registers and take flag into account

        # Store result
        mov.d $f0, $f24			# put result in register

        # Invert result, if flag is set
        mtc1.d $s2, $f16		# Move flag to cop. 1
        cvt.d.w $f16, $f16		# Convert flag to double
        mul.d $f0, $f0, $f16    # Multiply

        # Restore everything else
        lw $ra, 0($sp)			# Return addr
        lw $s0, 4($sp)			# Used Registers
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        ldc1 $f20, 16($sp)
        ldc1 $f24, 24($sp)
        ldc1 $f26, 32($sp)
        ldc1 $f28, 40($sp)
        addi $sp, $sp, 48

        jr $ra                  # Return

    power:
        # Calculate the power x^y or f12^f14

        # Store return adress
        addi $sp, $sp, -4		# Make space
        sw $ra, 0($sp)			# Store return adress

        # Exit condition: if y is 0, exit
        li.d $f16, 0.0			# Load 0
        c.eq.d $f14, $f16		# Check if y is 0
        bc1t power_end			# Then exit

        # Subtract y by 1 and do recursive call
        li.d $f16, 1.0			# Load 1 for subtraction
        sub.d $f14, $f14, $f16	# y = y-1
        jal power			    # Recursion
        mul.d $f0, $f12, $f0	# Return value

        # Restore return adress
        lw $ra, 0($sp)			# Load return adress
        addi $sp, $sp, 4		# Free space
        jr $ra                  # Go back

    power_end:
        # Return 1 on recursion end

        li.d $f0, 1.0			# Load return value

        # Restore return adress
        lw $ra, 0($sp)			# Load return adress
        addi $sp, $sp, 4		# Free space
        jr $ra                  # Go back

    cos:
        # Calculate cos(x)

        # Store return adress
        addi $sp, $sp, -4		# Make space
        sw $ra, 0($sp)			# Save return adress

        # Convert cos to sin
        ldc1 $f4, pi_half       # Load pi/2
        sub.d $f12, $f4, $f12	# Convert cos to sin

        # Calculate sin
        jal sin                 # Calculate sin

        # Restore return adress
        lw $ra, 0($sp)			# Load return adress
        addi $sp, $sp, 4		# Free the space

        # Go back
        jr $ra

    tan:
        # Calculate tan(x)
        # Takes sin(x) (f12) and cos(x) (f14)

        # Check if tan(x) can be calculated
        # only, if cos(x) is not 0!
        li.d $f4, 0.0           # Load 0
        c.eq.d $f14, $f4        # Compare cos(x) to 0
        bc1t tan_nan            # If cos(x) is 0, throw error

        # Otherwise calculate tan(x) = sin/cos
        div.d $f12, $f12, $f14  # Calculate
        li $v0, 3               # Prepare output
        jr $ra                  # Jump back to print output

    tan_nan:
        # Tan(x) can not be calculated
        # Print error
        la $a0, NaNErrorMessage       # Load error message
        li $v0, 4               # Prepare output
        jr $ra                  # Jump back to print


    print_pipe:
        # Print Pipe ( as column seperator )
        la $a0, columnSeperator
        li $v0, 4
        syscall
        jr $ra

    intervall_error:
        # User has entered a faulty intervall, give error and go back to main
        la $a0, intervalErrorMessage
        li $v0, 4
        syscall
        j main

    end:
        # Bye bye
        li $v0, 10
        syscall
