# This file contains function definitions and dictionaries for the
# RV32I ISA (with a few insrtuctions omitted). These are required
# for com.py to run.

# ======================== FUNCTIONS ================================
# ------------------------ ASK STRING -------------------------------
# Ask for a string (name of a file etc)
def ask_str(message='Say something', default='something'):
   inString = input('> '+message+' (default is "'+default+'"): ') or default
   # print('> Returning "'+inString+'".')
   return inString

# ------------------------- CHECK COMMENTS --------------------------
# Check comment
def chk_cmt(word):
   return (True if word[0] == '#' or word[0] == '\n' else False)

# ------------------ PSEUDOINSTRUCTIONS HANDLER ---------------------
# Pseudoinstruction handler. Substitutes pseudo instr. with proper one
def pseudo_handler(instruction):
   try:
      return pseudoInstr[instruction[0].upper()]
   except KeyError:
      return instruction
   
def get_dict(key, dictionary):
   try:
      return dictionary[key]
   except KeyError:
      print('# Error!\n# Unsupported key "{}" v.v'.format(key))
      raise KeyError

# ------------------- DECODE REGISTER ADDRESS -----------------------
# Get register index
def decode_reg(regName):
   if regName[0] == 'x': 
      try:
         regIdx = int(regName[1:])
      except ValueError:
         print(f'# Error!\n# Invalid register name "{regName}".')
         raise SyntaxError
   else:
      regIdx = get_dict(regName, altNames)
   if regIdx < 0 or regIdx > 31:
      print(f'# Error!\n# Index of "{regName}" out of range.')
      raise SyntaxError
   return '{0:05b}'.format(regIdx) 

# ----------------------- SHAMT GENERATOR ---------------------------
# Shamt generator. Shamt must fit on the 5 LSB of the 12 immediate bits
# of the I-type instructions.
def gen_shamt(shamtParam):
   try:
      shamtVal = int(shamtParam)
   except ValueError:
      print(f'# Error!\n# Invalid shamt immediate parameter "{shamtParam}".')
      raise SyntaxError
   else:
      if shamtVal < 0 or shamtVal > 31:
         print(f'# Error!\n# Shamt value "{shamtVal}" out of range.')
         raise SyntaxError
      return '{0:05b}'.format(shamtVal)

# ----------------------- 2'S COMPLEMENT STRING ---------------------
# I couldn't find a way to properly show 2's complement
def twos_comp(num, nBits):
		return '{0:b}'.format(((~abs(num)) + 1) & ((1 << nBits) - 1))

# -------------------- IMMEDIATE GENERATOR --------------------------
# Immediate generator. Meh... Could be improved but I'm tired.
def imm_gen(instrType, uns, immParam):
   try: 
      immVal = int(immParam)
   except ValueError:
      print(f'# Error!\n# Invalid immediate parameter "{immParam}".')
      raise SyntaxError
   else:
      if instrType == 'I':
         if uns == 'U':
            if immVal < 0 or immVal >= 1 << 12:
               print(f'# Error!\n# Immediate value "{immVal}" out of range.')
               raise SyntaxError
            else:
               return ['{0:012b}'.format(immVal), '']
         else:
            if immVal < -(1 << 11) or immVal >= 1 << 11:
               print(f'# Error!\n# Immediate value "{immVal}" out of range.')
               raise SyntaxError
            elif immVal < 0:
               return [twos_comp(immVal, 12), '']
            else:
               return ['{0:012b}'.format(immVal), '']
      
      elif instrType == 'S':
         if immVal < 0 or immVal >= 1 << 12:
            print(f'# Error!\n# Immediate value "{immVal}" out of range.')
            raise SyntaxError
         else:
            return ['{0:07b}'.format(immVal >> 5), '{0:05b}'.format(immVal & ((1 << 5) -1))]
      
      elif instrType == 'B':
         if uns == 'U':
            if immVal < 0 or immVal >= 1 << 13:
               print(f'# Error!\n# Immediate value "{immVal}" out of range.')
               raise SyntaxError
            elif immVal % 2:
               print(f'# Error!\n# Invalid branch target "{immVal}", it must be even.)')
               raise SyntaxError
            else:
               immStr = '{0:012b}'.format(immVal >> 1)
               return [immStr[0]+immStr[2:8], immStr[8:]+immStr[1]]
         else:
            if immVal < -(1 << 12) or immVal >= 1 << 12:
               print(f'# Error!1n# Immediate value "{immVal}" out of range.')
               raise SyntaxError
            elif immVal % 2:
               print(f'# Error!\n# Invalid branch target "{immVal}", it must be even.)')
               raise SyntaxError
            elif immVal < 0:
               immStr = twos_comp(immVal >> 1, 12)
               return [immStr[0]+immStr[2:8], immStr[8:]+immStr[1]]
            else:
               immStr = '{0:012b}'.format(immVal >> 1)
               return [immStr[0]+immStr[2:8], immStr[8:]+immStr[1]]
      
      elif instrType == 'U':
         if immVal < -(1 << 19) or immVal >= 1 << 19:
            print(f'# Error!\n# Immediate value "{immVal}" out of range.')
            raise SyntaxError
         elif immVal < 0:
            return [twos_comp(immVal, 20), '']
         else:
            return ['{0:020b}'.format(immVal), '']
      
      elif instrType == 'J':
         if immVal < -(1 << 20) or immVal >= 1 << 20:
            print(f'# Error!\n# Immediate value "{immVal}" out of range.')
            raise SyntaxError
         elif immVal < 0:
            immStr = twos_comp(immVal >> 1, 20)
            return [immStr[0]+immStr[10:]+immStr[9]+immStr[1:9], '']
         else:
            immStr = '{0:020b}'.format(immVal >> 1)
            return [immStr[0]+immStr[10:]+immStr[9]+immStr[1:9], '']

      else:
         print(f'# Error!\n# Unmatched instruction type "{instrType}".')
         raise KeyError

# ===================================================================

# ========================== DICTIONARIES ===========================
# This dictionaries are indexed by the name of an assembly 
# instruction or a name of the general purpose register and return 
# either directly the machine code (opcode, register address, etc) 
# or something else that someone else will use before assembling the 
# final machine code. The order in which instructions are listed is 
# the one from the Open RISC-V Reference Card.

# --------------------------- FIXED PART ----------------------------
# From Volume "I: RISC-V User-Level ISA V2.2", pag. 104
fixed = {
#  |name     |funct7       |funct3  |opcode
   # Shifts
   'SLL':   ['0000000',    '001',   '0110011'],
   'SLLI':  ['0000000',    '001',   '0010011'], # IMPORTANT:
   # Even if this is a I-type instruction, the 7 MSB of the imm field 
   # are treated as funct7 field, since they don't depend on the 
   # assembly parameters.
   'SRL':   ['0000000',    '101',   '0110011'],
   'SRLI':  ['0000000',    '101',   '0010011'], # Same
   'SRA':   ['0100000',    '101',   '0110011'],
   'SRAI':  ['0100000',    '101',   '0010011'], # Same again
   # Arithmetic
   'ADD':   ['0000000',    '000',   '0110011'],
   'ADDI':  ['',           '000',   '0010011'],
   'SUB':   ['0100000',    '000',   '0110011'],
   'LUI':   ['',           '',      '0110111'],
   'AUIPC': ['',           '',      '0010111'],
   # Logical
   'XOR':   ['0000000',    '100',   '0110011'],
   'XORI':  ['',           '100',   '0010011'],
   'OR':    ['0000000',    '110',   '0110011'],
   'ORI':   ['',           '110',   '0010011'],
   'AND':   ['0000000',    '111',   '0110011'],
   'ANDI':  ['',           '111',   '0010011'],
   # Compare
   'SLT':   ['0000000',    '010',   '0110011'],
   'SLTI':  ['',           '010',   '0010011'],
   'SLTU':  ['0000000',    '011',   '0110011'],
   'SLTIU': ['',           '011',   '0010011'],
   # Branches
   'BEQ':   ['',           '000',   '1100011'],
   'BNE':   ['',           '001',   '1100011'],
   'BLT':   ['',           '100',   '1100011'],
   'BGE':   ['',           '101',   '1100011'],
   'BLTU':  ['',           '110',   '1100011'],
   'BGEU':  ['',           '111',   '1100011'],
   # Jump & Link
   'JAL':   ['',           '',      '1101111'],
   'JALR':  ['',           '000',   '1100111'],
   # Loads
   'LB':    ['',           '000',   '0000011'],
   'LH':    ['',           '001',   '0000011'],
   'LBU':   ['',           '100',   '0000011'],
   'LHU':   ['',           '101',   '0000011'],
   'LW':    ['',           '010',   '0000011'],
   # Stores
   'SB':    ['',           '000',   '0100011'],
   'SH':    ['',           '001',   '0100011'],
   'SW':    ['',           '010',   '0100011']
}

# --------------------------- PARAMETERS ----------------------------
fields = {
#  |name     |param1    |param2     |param3     |format
   # Shifts
   'SLL':   ['rd',      'rs1',      'rs2',      'R'],
   'SLLI':  ['rd',      'rs1',      'shamt',    'I'],
   'SRL':   ['rd',      'rs1',      'rs2',      'R'],
   'SRLI':  ['rd',      'rs1',      'shamt',    'I'],
   'SRA':   ['rd',      'rs1',      'rs2',      'R'],
   'SRAI':  ['rd',      'rs1',      'shamt',    'I'],
   # Arithmetic
   'ADD':   ['rd',      'rs1',      'rs2',      'R'],
   'ADDI':  ['rd',      'rs1',      'imm',      'I'],
   'SUB':   ['rd',      'rs1',      'rs2',      'R'],
   'LUI':   ['rd',      'imm',      '-',        'U'],
   'AUIPC': ['rd',      'imm',      '-',        'U'],
   # Logical
   'XOR':   ['rd',      'rs1',      'rs2',      'R'],
   'XORI':  ['rd',      'rs1',      'imm',      'I'],
   'OR':    ['rd',      'rs1',      'rs2',      'R'],
   'ORI':   ['rd',      'rs1',      'imm',      'I'],
   'AND':   ['rd',      'rs1',      'rs2',      'R'],
   'ANDI':  ['rd',      'rs1',      'imm',      'I'],
   # Compare
   'SLT':   ['rd',      'rs1',      'rs2',      'R'],
   'SLTI':  ['rd',      'rs1',      'imm',      'I'],
   'SLTU':  ['rd',      'rs1',      'rs2',      'R'],
   'SLTIU': ['rd',      'rs1',      'imm',      'I'],
   # Branches
   'BEQ':   ['rd',      'rs1',      'imm',      'B'],
   'BNE':   ['rd',      'rs1',      'imm',      'B'],
   'BLT':   ['rd',      'rs1',      'imm',      'B'],
   'BGE':   ['rd',      'rs1',      'imm',      'B'],
   'BLTU':  ['rd',      'rs1',      'imm',      'B'],
   'BGEU':  ['rd',      'rs1',      'imm',      'B'],
   # Jump & Link
   'JAL':   ['rd',      'imm',      '-',        'J'],
   'JALR':  ['rd',      'rs1',      'imm',      'I'],
   # Loads
   'LB':    ['rd',      'rs1',      'imm',      'I'],
   'LH':    ['rd',      'rs1',      'imm',      'I'],
   'LBU':   ['rd',      'rs1',      'imm',      'I'],
   'LHU':   ['rd',      'rs1',      'imm',      'I'],
   'LW':    ['rd',      'rs1',      'imm',      'I'],
   # Stores
   'SB':    ['rs1',     'rs2',      'imm',      'S'],
   'SH':    ['rs1',     'rs2',      'imm',      'S'],
   'SW':    ['rs1',     'rs2',      'imm',      'S']
}

# ---------------------- PSEUDOINSTRUCTIONS -------------------------
pseudoInstr = {
#  |name     |instr       |param1    |param2    |param3    
   'NOP':   ['addi',      'x0',      'x0',      '0']
}

# ----------------------- REGISTER NAMES ----------------------------
altNames = {
#  |asm     |address
   'zero':  0,
   'ra':    1,
   'sp':    2,
   'gp':    3,
   'tp':    4,
   't0':    5,
   't1':    6,
   't2':    7,
   'fp':    8,
   's0':    8,
   's1':    9,
   'a0':    10,
   'a1':    11,
   'a2':    12,
   'a3':    13,
   'a4':    14,
   'a5':    15,
   'a6':    16,
   'a7':    17,
   's2':    18,
   's3':    19,
   's4':    20,
   's5':    21,
   's6':    22,
   's7':    23,
   's8':    24,
   's9':    25,
   's10':   26,
   's11':   27,
   't3':    28,
   't4':    29,
   't5':    30,
   't6':    31
}

# ===================================================================