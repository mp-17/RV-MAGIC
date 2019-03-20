#__start:
	li x1, 7            # load x1 with 7 (number of elements)       0
	li x2, 16           # put in x2 the address of v (16)           4
	li x3, 8            # put in x3 the address of m (8)            8
	lw x4, 0(x3)   		# init x4 with max value (high)             12
#loop:
    beq x1, x0, 48      # check all elements have been tested       16
	lw x5, 0(x2)        # load new element in x5                    20
	srai x6, x5, 31     # apply shift to get sign mask in x6        24
	xor x7, x5, x6      # x7 = sign(x5)^x5 (invert x5 if negative)  28
	andi x6, x6, 1      # x6 &= 1 (carry in)                        32
	add x7, x7, x6      # x7 += x6 (add the carry in)               36
	addi x2, x2, 4      # point to next element		                40
	addi x1, x1, -1     # decrease x1 by 1                          44
	slt x8, x7, x4      # x8 = (x7 < x4) ? 1 : 0                    48
	beq x8, x0, -36     # next element                              52
	add x4, x7, x0      # update min	                            56
	jal x0, -44         # next element                              60    
#done:
	sw 0(x3), x4        # store the result                          64