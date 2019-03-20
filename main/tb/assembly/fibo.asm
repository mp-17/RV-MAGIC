li x5, 7
li x6, 2
jal ra, 8 # FIB
j 72 # EXIT

# FIB:
    bge x5, x6, 12 # REC 
    addi x7, x5, 0
    jalr x0, 0(x1)
    # Handled Base Case

# REC:
    # Handling Rec. Case

    addi sp, sp, -12
    sw 0(sp), x1
    sw 4(sp), x5

    addi x5, x5, -1
    jal ra, -28 # FIB


    sw 8(sp), x7
    lw x5, 4(sp)
    addi x5, x5, -2
    jal ra, -44 # FIB 

    lw x13, 8(sp)
    add x7, x13, x7


    lw ra, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)

# EXIT: