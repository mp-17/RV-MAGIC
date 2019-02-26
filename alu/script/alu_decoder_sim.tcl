vlog -work ../sim/work/ ../src/alu_decoder.sv 
vlog -work ../sim/work/ ../tb/alu_decoder_tb.sv
vsim work.alu_decoder_tb
do ../sim/alu_decoder_wave.do
run -all

