li sp, 32
li x5, 7
li x6, 2
jal ra, 8 # FIB
j 72 # EXIT

# FIB:
    bge x5, x6, 12 # REC 
    addi x7, x5, 0
    jalr x0, 0(ra)
    # Handled Base Case

# REC:
    # Handling Rec. Case

    addi sp, sp, -12
    sw x1, 0(sp)
    sw x5, 4(sp)

    addi x5, x5, -1
    jal ra, -28 # FIB


    sw x7, 8(sp)
    lw x5, 4(sp)
    addi x5, x5, -2
    jal ra, -44 # FIB 

    lw x13, 8(sp)
    add x7, x13, x7


    lw ra, 0(sp)
    addi sp, sp, 12
    jalr x0, 0(ra)

# EXIT: