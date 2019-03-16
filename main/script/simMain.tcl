# delete work if it already exists 
if {[file exists work]} {
	vdel -lib work -all
}

# create a rtl_work library
vlib work

# map "work" name to work" folder
vmap work work

# compile all the def files
vlog -work work -sv ../../common/src/rv32i_defs.sv
vlog -work work -sv ../../common/src/*.sv

# compile all the src files
vlog -work work -sv ../../*/src/*.sv

# compile the TB files