#################
# Basic VERSION	
# This program takes an array v and computes
# min{|v[i]|}, the minimum of the absolute value,
# where v[i] is the i-th element in the array
	.data
	.align	2
Nm1=7
v:
	.word	10
	.word	-47
	.word	22
	.word	-3
	.word	15
	.word	27
	.word	-4
m:
	.word	0

	.text
	.align	2
	.globl	__start
__start:
	li $s0,Nm1      # load $s0 with Nm1
	la $a0,v        # put in $a0 the address of v
	la $a1,m        # put in $a1 the address of m	
	li $t5,0x3fffffff # init $t5 with max pos
loop:
	beq $s0,$0,done # check all elements have been tested
	lw $t0,0($a0)   # load new element in $t0
	sra $t1,$t0,31  # apply shift to get sign mask in $t1	
	xor $t2,$t0,$t1 # $t2 = sign($t0)^$t0
	andi $t1,$t1,0x1 # $t1 &= 0x1 (carry in)
	add $t2,$t2,$t1 # $t2 += $t1 (add the carry in)
	add $a0,$a0,4   # point to next element		
	sub $s0,$s0,1   # decrease $s0 by 1
	slt $t3,$t2,$t5 # $t3 = ($t2 < $t5) ? 1 : 0
	beq $t3,$0,loop # next element
	add $t5,$t2,$0  # update min	
	j loop          # next element
done:
	sw $t5,0($a1)   # store the result
endc:	
	j endc          # infinite loop
	nop
	nop