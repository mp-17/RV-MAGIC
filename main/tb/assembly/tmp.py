tmpList = []
i = 1
with open('1-instr_list_no_jump.txt', 'r') as fIn:
	for line in fIn:
		tmpList += [str(int(line.split()[2]) * 2**(12))]
		if (i == 33):
			break
		i += 1

with open('tmp.txt', 'w') as fOut:
	for elm in tmpList:
		fOut.write(elm + '\n')