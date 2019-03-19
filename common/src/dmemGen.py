#! /usr/bin/python3

from rv32i_defs import get_root
from instrConverter import bin2litEndByte

ROOT_DIR = get_root('RV-MAGIC')
inFileName = ROOT_DIR+'/main/tb/bin_mc/private/dmemb.mem'
outFileName = ROOT_DIR+'/main/tb/hex_mc/private/dmemh.mem'
with open(inFileName, 'w') as memFile:
   for i in range((1 << 8)):
      memFile.write('{0:032b}\n'.format(i))

bin2litEndByte(inFileName, outFileName, 'hex', 32)
   