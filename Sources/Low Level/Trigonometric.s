#
#   Trigonometric.s
#   Trigonometric
#
#   Created by Niklas Sauer, Malcolm Malam on 02.05.17.
#   Copyright © 2017 DHBW Stuttgart. All rights reserved.
#

.data
    PI:                     .double     3.141592653589793238462643383279502884197169399375105820974
    halfPI:                 .double     1.570796326794896619231321691639751442098584699687552910487
    approximations:         .word       6

    welcomeMessage:         .asciiz     "Tabulates trigonometric function results for n equidistant values in specified interval [x(min), x(max)].\n"
    partitionsQuestion:     .asciiz     "\nPlease input the desired number (n) of equidistant values: "
    xMinQuestion:           .asciiz     "\nPlease specify the interval start [x(min)]: "
    xMaxQuestion:           .asciiz     "\nPlease specify the interval end [x(max)]: "

    NaNErrorMessage:        .asciiz     "ERROR - Undefined result (NaN)."
    intervalErrorMessage:   .asciiz     "ERROR - Interval end [x(max)] must be larger than interval start [x(min)].\n"

    tableHeader:            .asciiz     "\nx\t| sin(x)\t\t\t| cos(x)\t\t\t| tan(x)\n"
    columnSeperator:        .asciiz     "\t|"
    rowSeperator:           .asciiz     "-----------------------------------------------------------------------------------------------\n"
    lineBreak:              .asciiz     "\n"


.text
.globl main
    main:
        # print progam purpose
        la $a0, welcomeMessage  # load welcome message
        li $v0, 4               # load print_string system call upcode
        syscall                 # execute system call

        # ask user for interval start
        la $a0, xMinQuestion
        li $v0, 4
        syscall

        # set $f20 = user specified interval start x(min)
        li $v0, 7               # load read_double system call upcode
        syscall
        mov.d $f20, $f0         # move syscall result to $f20

        # ask user for interval end
        la $a0, xMaxQuestion
        li $v0, 4
        syscall

        # set $f22 = user specified interval end x(max)
        li $v0, 7
        syscall
        mov.d $f22, $f0

        # CURRENT STATE
        # xMin:     $f20
        # xMax:     $f22

        # check if xMin < xMax, if true: print error and restart
        c.lt.d $f20, $f22
        bc1f intervalBreakCondition

        # ask user for number of equidistant values (n)
        la $a0, partitionsQuestion
        li $v0, 4
        syscall

        # set $f24 = user specified number of equidistant values (n) -> rows
        li $v0, 7
        syscall
        mov.d $f24, $f0

        # CURRENT STATE
        # xMin:     $f20
        # xMax:     $f22
        # n:        $f24

        # set $f26 = partition size
        sub.d $f22, $f22, $f20	# calculate intervalLength = xMax - xMin
        div.d $f26, $f22, $f24	# calculate partition size = intervalLength / n

        # CURRENT STATE
        # xMin:             $f20
        # xMax:             $f22
        # n:                $f24
        # partitionSize:    $f26

        # print table header
        la $a0, tableHeader
        li $v0, 4
        syscall
        la $a0, rowSeperator
        syscall

        # set $28 = current partition counter (= 0) -> currentRow
        li.d $f28, 0.0

    tableCalcLoop:
        # ENTER STATE
        # xValue:           $f20
        # rows:             $f24
        # partitionSize:    $f26
        # currentRow:       $f28

        # exit program, if rows <= currentRow
        c.le.d $f24, $f28
        bc1t exit

        # set $f12 = xValue, print
        mov.d $f12, $f20            # sine awaits value in $f12
        li $v0, 3                   # load print_double system call upcode
        syscall

        jal printColumnSeperator

        # set $f30 = sine(xValue)
        jal sine
        mov.d $f30, $f0             # store result for later tangent calculation

        # print sine(xValue) result
        mov.d $f12, $f0             # print_double awaits value in $f12
        li $v0, 3
        syscall

        jal printColumnSeperator

        # calculate cosine(xValue)
        mov.d $f12, $f20            # cosine awaits value in $f12
        jal cosine

        # print cosine(xValue) result
        mov.d $f12, $f0
        li $v0, 3
        syscall

        jal printColumnSeperator

        # calculate tangent(xValue)
        mov.d $f12, $f30            # tangent awaits sine(xValue) in $f12
        mov.d $f14, $f0             # tangent awaits cosine(xValue) in $f14
        jal tangent

        # print tangent(x)
        mov.d $f12, $f0
        li $v0, 3
        syscall

        # print line break
        la $a0, lineBreak
        li $v0, 4
        syscall

        # print row seperator
        la $a0, rowSeperator
        li $v0, 4
        syscall

        # set xValue = xValue + partitionSize
        add.d $f20, $f20, $f26

        # set currentRow = currentRow + 1
        li.d $f4, 1.0
        add.d $f28, $f28, $f4

        # jump to loop head to execute next recursion step
        j tableCalcLoop

    sine:
        # ENTER STATE
        # x:        $f12
        # sign:     $a0

        # branch setup
        addi $sp, $sp, -4		# make space
        sw $ra, 0($sp)			# store return address

        # set $a0 to initial result sign (= 1)
        li $a0, 1

        # check if x is negative, if true: map into positive number space
        li.d $f4, 0.0
        c.lt.d $f12, $f4
        bc1t mapToPositive

        # map x irrespective of position into defined interval (-halfPI, halfPI)
        jal mapToDefinedIntervalLoop

        # restore saved registers
        lw $ra, 0($sp)

        # free stack
        addi $sp, $sp, 4

        # exit sine function, jump to calling register
        jr $ra

    mapToPositive:
        # ENTER STATE
        # x:        $f12

        # set x = -x + PI
        li.d $f4, -1.0
        mul.d $f12, $f12, $f4   # multiply negative x with (-1)
        ldc1 $f4, PI
        add.d $f12, $f12, $f4

        # map x irrespective of position into defined interval (-halfPI, halfPI)
        j mapToDefinedIntervalLoop

    mapToDefinedIntervalLoop:
        # ENTER STATE
        # x:        $f12

        # check if x =< PI/2, if true: break and calculate sine of x
        ldc1 $f4, halfPI
        c.le.d $f12, $f4
        bc1t sine0

        # if false: set x = x - PI, set sign = -sign
        ldc1 $f4, PI
        sub.d $f12, $f12, $f4
        li, $t0, -1
        mul $a0, $a0, $t0

        # jump to loop head to execute next recursion step
        j mapToDefinedIntervalLoop

    sine0:
        # ENTER STATE
        # x:        $f12
        # sign:     $a0

        # branch setup
        addi $sp, $sp, -48		# make space
        sw $ra, 0($sp)			# store return adress

        # function setup
        #
        # set $s0 = current approximation term count (= 1)
        sw $s0, 4($sp)
        li $s0, 1

        # set $s1 = desired number of approximations (= 6)
        sw $s1, 8($sp)
        lw $s1, approximations

        # set $s2 = calculated sign from mapping to defined interval
        sw $s2, 12($sp)
        move $s2, $a0

        # set $f20 (lastTerm) = mapped x
        sdc1 $f20, 16($sp)
        mov.d $f20, $f12

        # set $f24 (result) = mapped x
        sdc1 $f24, 24($sp)
        mov.d $f24, $f12

        # store current approximation term count as double
        sdc1 $f28, 40($sp)

        # set constant exponent/factor for future calculations
        li.d $f14, 2.0

        # set $26 to constant x^2 to calculate numerator of next taylor term  by multiplication
        sdc1 $f26, 32($sp)
        jal power
        mov.d $f26, $f0

    sine0CalcLoop:
        # ENTER STATE
        # approximations:   $s1
        # counter:          $s0
        # lastTerm:         $f20
        # result:           $f24

        # exit, if total desired number of approximation terms has been reached
        bge $s0, $s1, sine0BreakCondition

        # copy current approximation term count as double to coprocessor 1
        mtc1.d $s0, $f28
        cvt.d.w $f28, $f28

        # calculate denominator of next taylor term
        li.d $f4, 2.0
        mul.d $f16, $f28, $f4	# $f16  = (2*i)
        li.d $f6, 1.0
        add.d $f18, $f16, $f6	# $f18  = (2*i+1)
        mul.d $f4, $f16, $f18	# $f04  = (2*i+1) * (2*i)

        # set $f20 (nextTerm)
        div.d $f16, $f26, $f4	# calculate difference factor (x^2 / (2*i+1) * (2*i))
        mul.d $f20, $f20, $f16	# multiply difference factor with last taylor term

        # set appropriate sign (= pow(-1, counter) * nextTerm) of next taylor term
        li.d $f12, -1.0
        mov.d $f14, $f28
        jal power
        mul.d $f0, $f0, $f20

        # add next taylor term to intermediate result
        add.d $f24, $f24, $f0

        # increment current approximation term count
        addi $s0, $s0, 1

        # jump to loop head to execute next recursion step
        j sine0CalcLoop

    sine0BreakCondition:
        # ENTER STATE
        # sign:   $s2
        # result: $f24

        # store final result
        mov.d $f0, $f24

        # multiply final result with sign calculated from mapping into defined interval
        mtc1.d $s2, $f16
        cvt.d.w $f16, $f16
        mul.d $f0, $f0, $f16

        # restore saved registers
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        ldc1 $f20, 16($sp)
        ldc1 $f24, 24($sp)
        ldc1 $f26, 32($sp)
        ldc1 $f28, 40($sp)

        # free stack
        addi $sp, $sp, 48

        # exit sine0 function, jump to calling register
        jr $ra

    power:
        # ENTER STATE
        # x:    $f12
        # e:    $f14

        # branch setup
        addi $sp, $sp, -4		# make space
        sw $ra, 0($sp)			# store return adress

        # exit, if exponent e = 0 -> result = 1
        li.d $f16, 0.0
        c.eq.d $f14, $f16
        bc1t powerBreakCondition

        # jump to loop head to execute next recursion step with decremented exponent e = e - 1
        li.d $f16, 1.0
        sub.d $f14, $f14, $f16
        jal power

        # set result
        mul.d $f0, $f12, $f0

        # prepare for exit
        lw $ra, 0($sp)      # restore saved registers
        addi $sp, $sp, 4    # free stack
        jr $ra              # exit power function, jump to calling register

    powerBreakCondition:
        # load return value result = 1
        li.d $f0, 1.0

        # prepare for exit
        lw $ra, 0($sp)      # restore saved registers
        addi $sp, $sp, 4    # free stack
        jr $ra              # exit power break condition, jump to calling register

    cosine:
        # ENTER STATE
        # x:    $f12

        # branch setup
        addi $sp, $sp, -4		# make space
        sw $ra, 0($sp)			# save return adress

        # set x = PI/2 - x
        ldc1 $f4, halfPI
        sub.d $f12, $f4, $f12

        # calculate sine(x)
        jal sine

        # prepare for exit
        lw $ra, 0($sp)      # restore saved registers
        addi $sp, $sp, 4		# free stack
        jr $ra              # exit cosine function, jump to calling register

    tangent:
        # ENTER STATE
        # sine(x):      $f12
        # cosine(x):    $f14

        # exit, if cosine(x) = 0 as division by zero is undefined
        li.d $f4, 0.0
        c.eq.d $f14, $f4
        bc1t tangentBreakCondition

        # calculate tangent(x) = sine(x)/cosine(x)
        div.d $f12, $f12, $f14

        # store final result
        mov.d $f0, $f12

        # exit tangent function, jump to calling register
        jr $ra

    tangentBreakCondition:
        la $a0, NaNErrorMessage         # load string literal
        li $v0, 4                       # load print_string system call upcode
        syscall                         # execute system call
        jr $ra                          # exit tangent function, jump to calling register

    printColumnSeperator:
        la $a0, columnSeperator
        li $v0, 4
        syscall
        jr $ra

    intervalBreakCondition:
        la $a0, intervalErrorMessage
        li $v0, 4
        syscall
        j main

    exit:
        li $v0, 10                      # load exit system call upcode
        syscall                         # execute system call
