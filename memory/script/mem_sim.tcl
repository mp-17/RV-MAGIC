vlog -work ../sim/work/ ../src/mem.sv 
vlog -work ../sim/work/ ../tb/mem_tb.sv
vsim work.mem_tb
do ../sim/wave.do
run -all