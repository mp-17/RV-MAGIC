# Support functions to allow translation from binary instructions in rows to bin or hex instructions, 
# one byte per row, in little endian format

# read well from the keyboard without reading also arrow keys
import readline

# default file paths
inFilePath = 'private/3-fwd_test.intermediate'
outFilePath = 'private/3-fwd_test.riscv'

# take a binary string and convert it to hex without prefix
def bin2hex(binaryStr):
	return format(int(binaryStr, 2), '02X')

#
# Binary to little endian bytes function
#
# This function takes binary instruction rows from an inFile and writes them one byte per row (in little endian format)
# on an outFile.
#
# inFilePath : path of the input file. It has to contain only rows with ASCII characters representing binary numbers.
# Each binary number has to be on the same number of bits instruction_width
#
# outFilePath : path of the output file.
#
# binOrHex_outMode : if this string begins with 'b', the output file will be in binary. Otherwise, in hexadecimal
#
# instruction_width : the legth of each input instruction
#
def bin2litEndByte(inFilePath, outFilePath, binOrHex_outMode, instruction_width):
	
	BYTE_WIDTH = 8

	try:
		with open(inFilePath, 'r') as fIn, open(outFilePath, 'w') as fOut:
			for binInstr in fIn:
				for i in range(instruction_width, 0, -BYTE_WIDTH):
					# RISC-v adopts little endian storage default
					tmpByte_bin = binInstr[i-7:i]
					# convert the byte in hex
					tmpByte_hex = bin2hex(tmpByte_bin)
					# choose the correct format
					if (binOrHex_outMode[0] == 'b'):
						tmpByte = tmpByte_bin
					else:
						tmpByte = tmpByte_hex
					# write the byte
					fOut.write(tmpByte + '\n')

	except FileNotFoundError:
		print('Error: input file or output folder does not exist.', '\n')
		exit(1)

# autosufficiency of the script
if __name__ == "__main__":
	print('')
	print("Let's convert some instructions! I assume they are 32-bits wide. If not, modify me with an editor.", '\n')
	inFilePath = input('Insert the inFilePath (default is "' + inFilePath + '"): ') or inFilePath
	outFilePath = input('Insert the outFilePath (default is "' + outFilePath + '"): ') or outFilePath
	print('')
	bin2litEndByte(inFilePath, outFilePath, 'hex', 32)