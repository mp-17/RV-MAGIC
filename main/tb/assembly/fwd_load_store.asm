# Store the value just read
li x1, 5
lw x2, 16(x0) # x2 = DMEM[4] = 4
sw 32(x2), x1 # DMEM[9] = 5