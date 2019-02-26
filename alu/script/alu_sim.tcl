vlog -work ../sim/work/ ../src/alu.sv 
vlog -work ../sim/work/ ../tb/alu_tb.sv
vsim work.alu_tb
do ../sim/alu_wave.do
run -all

