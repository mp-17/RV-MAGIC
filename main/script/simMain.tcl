# delete work if it already exists 
if {[file exists work]} {
	vdel -lib work -all
}

# create a rtl_work library
vlib work

# map "work" name to work" folder
vmap work work

# compile all the src files
vlog -work work -sv ../../*/src/*.sv

# compile the TB files
vlog -work work -sv ../../main/tb/*.sv

# sim command
vsim work.main_tb
do ../sim/wave.do
run 2300 ns

# Zoom
wave zoom in
wave cursor time -time 0ns 1
wave cursor see -at 0 1