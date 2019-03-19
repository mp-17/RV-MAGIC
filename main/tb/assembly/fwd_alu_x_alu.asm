# ALU op after ALU op with one instruction in between
li x2, 3 #           x2  = 0b000000011
addi x13, x0, 255 #  x13 = 0b011111111
nop #                -
xor x3, x13, x2 #    x3  = 0b011111100