#! /usr/bin/python3

info = """# ================================ INFO =============================
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
#   assembly name ("ra", "sp", etc.).
#
# - Offset field can be passed both as standalone immediate parameter
#   ("lw x2, x1, 16") and parenthesis ("lw x2, 16(x1)")
#
# - Many pseudoinstruction are supported. Those standing for more 
#   than a single instruction are not implemented yet.
#
# Usage:
# - If run without arguments, the script will ask for everything
#   that's necessary
# - If run with arguments, they are:
#   argv[1]: Name of the source file relative to 
#            "/RV-MAGIC/main/tb/assembly/". If "help" is passed 
#            instead, an help message will be shown.
#   argv[2]: Condition to perform hex conversion of the output
#            machine code. Write "n", "0", "no" case insensitive to 
#            say that you don't need it.
#
# com.py will exit with the following codes:
# 0. Success! Everything went fine (most likely)
# 1. Cannot open the requested assembly input file
# 2. Syntax error
# 3. Requested instruction or parameter not supported by com.py
#    dictionaries
# ===================================================================\n"""

import readline
import datetime
import sys
import os

from instrConverter import bin2litEndByte

from rv32i_defs import *

assDir = '/main/tb/assembly'
binDir = '/main/tb/bin_mc'
hexDir = '/main/tb/hex_mc'

print("""\n> =================================================================
>              {date} - Welcome to com.py
> =================================================================\n""".format(date=datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')))

if len(sys.argv) > 1 and (sys.argv[1] in ['help', 'h', '--help', '-h', '0']):
   print(info)
   sys.exit(0) # Terminate

# Get repo's root directory
repoRoot = get_root('RV-MAGIC')
inPath = repoRoot+assDir
binOutPath = repoRoot+binDir
hexOutPath = repoRoot+hexDir

# Check if the assembly file is passed as argument
try:
   fileName = sys.argv[1]
   inFileName = fileName
except IndexError:
   # Ask for the name of the assembly file
   fileName = ask_str('Input the assembly file name relative to "{}"'.format(assDir), '/private/ass_test.txt')
   inFileName = inPath + fileName

fileName = '/' + fileName.split('/')[-1]
binOutFileName = binOutPath + fileName.split('.')[0] + '.mc'
hexOutFileName = hexOutPath + fileName.split('.')[0] + '.riscv'

try:
   convertInHex = sys.argv[2]
except IndexError:   
   # Ask if a conversion in HEX is needed
   convertInHex = ask_str('Do you want to convert the result also in .riscv format, with instructions in HEX,\n  one byte per row, using little endian storage format?', 'y')

open(binOutFileName, 'w').close() # Prepare blank output file

remainders = 3

while True:
   try:
      with open(inFileName, 'r') as assembly:
         print('\n> Assembling "'+inFileName+'"...')
         i = 1
         # Parse the assembly file
         for line in assembly:
            words = line.split()
            if chk_cmt(line[0]): continue # Check if the entire line is commented
            aInstrPrint = '{:6}'.format(str(i) + ') ')
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

            print(f'>\t{aInstrPrint:28}=>\t', end=' ') # Print assembly instruction being processed
            
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
            with open(binOutFileName, 'a') as mcode:
               mcode.write(''.join(mInstr)+'\n') # Also print machine code to the output file
               
      break

   # Exception handling
   except OSError: # Error opening file
      print('# Error. '+' File "'+inFileName+'" does not exist. '+str(remainders)+' attempt(s) remaining.')
      if not remainders: 
         print('\n> An error occurred while opening the assembly file. Exiting now...')
         sys.exit(1)
      inFileName = ask_str('Input the assembly file name', 'private/test.txt')
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

print()
print('> BIN file successfully created:\n\t{}\n'.format(binOutFileName))

# convert the bin file to an hex file in little endian format, one byte per row
dontConvertList = ['n', 'N', 'no', 'No', '0', 0]
if convertInHex in dontConvertList:
   pass
else:
   bin2litEndByte(binOutFileName, hexOutFileName, 'hex', 32)
   # Print hex file location
   print('> HEX file successfully created:\n\t{}\n'.format(hexOutFileName))
   try:
      simCode = sys.argv[3]
   except IndexError:
      simCode = ask_str('Do you want to simulate the produced code (y/n)?', 'No')
   # Ask if simulation is required
   if simCode.upper() in ['Y', 'YES', 'YEP']:
      notFound = True
      oldFile = []
      with open(repoRoot+'/main/tb/mainTB_param.sv') as tbParam:
         tbParamLines = tbParam.readlines()
         i = 0
         for line in tbParamLines:
            if 'INSTRUCTIONS_FILE' in line:
               oldFile[:] = tbParamLines[:]
               tbParamLines[i] = '`define INSTRUCTIONS_FILE "{}"\n'.format(hexOutFileName)
               notFound = False
               break
            i += 1
      if notFound:
         print('# Error. Missing parameter "INSTRUCTION_FILE".')
         sys.exit(4)
      else:
         with open(repoRoot+'/main/tb/mainTB_param.sv', 'w') as tbParam:
            tbParam.write(''.join(tbParamLines))
         print('> Running Modelsim...')
         os.system("""cd {}/main/sim/\nvsim -do ../script/simMain.tcl""".format(repoRoot))
         with open(repoRoot+'/main/tb/mainTB_param.sv', 'w') as tbParam:
            tbParam.write(''.join(oldFile))

         
