vlog -work ../sim/work/ ../src/rf.sv 
vlog -work ../sim/work/ ../tb/rf_tb.sv
vsim work.rf_tb
do ../sim/wave.do
run -all