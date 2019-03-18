#! /usr/bin/python3

# ================================ INFO =============================
# This is an assembler from RISC-V RV32I ISA assembly to machine code
# for the RV-MAGIC. So yes, it is an assembler, but the word 
# "assembler" doesn't contain "py" within it. "Compiler" doesn't
# either, but "com.py" sounds great so... An assembler can be seen as
# a very simple compiler for a specific assembly language. And there
# you are, let us introduce you com.py, your RV-MAGIC hum... 
# Assembler.
#
# - The "synch", "environment" and "CSR" instructions are not
#   supported (yet).
#
# - Registers can be called by architecture name ("x#") or by 
#   assembly name ("ra", "sp", etc.)
#
# - Only the "nop" pseudoinstruction is supported for now. Others
#   will be added in the near future
#
# com.py will exit with the following codes:
# 0. Success! Everything went fine (most likely)
# 1. Cannot open the requested assembly input file
# 2. Syntax error
# 3. Requested instruction or parameter not supported by com.py
#    dictionaries
# ===================================================================

import readline
import datetime
import sys

from instrConverter import bin2litEndByte

from rv32i_defs import *

print("""\n> =================================================================
>              {date} - Welcome to com.py
> =================================================================\n""".format(date=datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

# Check if the assembly file is passed as argument
try:
   fileName = sys.argv[1]
except IndexError:
   # Ask for the name of the assembly file
   fileName = ask_str('Input the assembly file name', 'private/test.txt')

try:
   outFileName = sys.argv[2]
except IndexError:   
   # Ask for output file name
   outFileName = ask_str('Input the output file name', 'private/mcode.txt')
open(outFileName, 'w').close() # Prepare blank output file

try:
   convertInHex = sys.argv[3]
except IndexError:   
   # Ask if a conversion in HEX is needed
   convertInHex = ask_str('Do you want to convert the result also in .riscv format, with instructions in HEX, one byte per row, using little endian storage format? Default is "y".', 'y')

remainders = 3

while True:
   try:
      with open(fileName, 'r') as assembly:
         print('\n> Assembling "'+fileName+'"...')
         i = 1
         # Parse the assembly file
         for line in assembly:
            words = line.split()
            if chk_cmt(line[0]): continue # Check if the entire line is commented
            aInstrPrint = str(i)+') '
            i += 1

            # Parse line and check for comments
            aInstr = []
            mInstr = ['']*6

            for w in words:
               if chk_cmt(w): # Skip to next line if a comment is found
                  break
               else:
                  aInstrPrint += w+' '
                  aInstr.append(w.rstrip(',')) # "clean" assembly instruction

            aInstr = pseudo_handler(aInstr)
            instrName = aInstr[0].upper()
            instrParam = aInstr[1:]

            print(f'>\t{aInstrPrint:25}=>\t', end=' ') # Print assembly instruction being processed
            
            # Assemble machine instruction 
            # 1) funct7, funct3, opcode ("fixed part")
            mInstr[0] = get_dict(instrName, fixed)[0]
            mInstr[3] = get_dict(instrName, fixed)[1]
            mInstr[5] = get_dict(instrName, fixed)[2]
            
            # 2) Parameters ("variable part")
            instrFields = get_dict(instrName, fields)
            instrType = instrFields[3]
            j = 0
            for param in instrParam:
               if instrFields[j] == 'rd':
                  mInstr[4] = decode_reg(param)
               elif instrFields[j] == 'rs1': 
                  mInstr[2] = decode_reg(param)
               elif instrFields[j] == 'rs2':
                  mInstr[1] = decode_reg(param)
               elif instrFields[j] == 'shamt':
                  mInstr[1] = gen_shamt(param)
               elif instrFields[j] == 'imm':
                  imm = imm_gen(instrType, param)
                  mInstr[0] = imm[0]
                  mInstr[4] += imm[1]
               else:
                  print('# Error. Something is wrong in one of the dictionaries.')
                  raise KeyError 
               j += 1

            # Assemble machine binary instruction
            print(f'{instrFields[3]}-type: ', end='')
            mInstrPrint = ' '.join(mInstr).strip()
            print(mInstrPrint) # Print final result
            with open(outFileName, 'a') as mcode:
               mcode.write(''.join(mInstr)+'\n') # Also print machine code to the output file
               
      break

   # Exception handling
   except OSError: # Error opening file
      print('# Error. '+' File "'+fileName+'" does not exist. '+str(remainders)+' attempt(s) remaining.')
      if not remainders: 
         print('\n> An error occurred while opening the assembly file. Exiting now...')
         sys.exit(1)
      fileName = ask_str('Input the assembly file name', 'private/test.txt')
      remainders -= 1

   except SyntaxError:
      print('# Error. Syntax error detected. Check previous error messages.\n> Exiting now...')
      sys.exit(2)

   except KeyError:
      print('# Error. Something went wrong trying to parse an instruction.\n> Exiting now...')
      sys.exit(3)

   except: # Unexpected errors, not handled
      print('# Unexpected Error: {}. Exiting now...'.format(sys.exc_info()[0]))
      raise

# convert the bin file to an hex file in little endian format, one byte per row
dontConvertList = ['n', 'N', 'no', 'No', 0]
if convertInHex in dontConvertList:
   pass
else:
   bin2litEndByte(outFileName, outFileName + '.riscv', 'hex', 32)