onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Interface
add wave -noupdate /main_tb/DUV/clk
add wave -noupdate /main_tb/DUV/rst_n
add wave -noupdate -radix unsigned /main_tb/DUV/I_MEM_addr
add wave -noupdate /main_tb/DUV/I_MEM_memRead
add wave -noupdate -radix hexadecimal /main_tb/DUV/I_MEM_dataOut
add wave -noupdate -radix unsigned /main_tb/DUV/D_MEM_addr
add wave -noupdate -radix decimal /main_tb/DUV/D_MEM_dataIn
add wave -noupdate /main_tb/DUV/D_MEM_memRead
add wave -noupdate /main_tb/DUV/D_MEM_memWrite
add wave -noupdate /main_tb/DUV/D_MEM_memMode
add wave -noupdate -radix decimal /main_tb/DUV/D_MEM_dataOut
add wave -noupdate -divider Control
add wave -noupdate -expand -group HDU /main_tb/DUV/HDU_stall_n
add wave -noupdate -expand -group HDU /main_tb/DUV/HDU_flush_IdEx
add wave -noupdate -expand -group HDU /main_tb/DUV/HDU_flush_IfId_ExMem
add wave -noupdate -group CU /main_tb/DUV/CU_RF_write
add wave -noupdate -group CU /main_tb/DUV/CU_D_MEM_write
add wave -noupdate -group CU /main_tb/DUV/CU_D_MEM_read
add wave -noupdate -group CU /main_tb/DUV/CU_RS1_PC_ALU_SRC_MUX_sel
add wave -noupdate -group CU /main_tb/DUV/CU_RS2_IMM_ALU_SRC_MUX_sel
add wave -noupdate -group CU /main_tb/DUV/CU_DMEM_ALU_WB_MUX_sel
add wave -noupdate -group CU /main_tb/DUV/CU_jump
add wave -noupdate -group CU /main_tb/DUV/CU_branch
add wave -noupdate -group CU /main_tb/DUV/CU_jalr
add wave -noupdate -group CU /main_tb/DUV/CU_D_MEM_mode
add wave -noupdate -group CU /main_tb/DUV/CU_immType
add wave -noupdate -expand -group NEXT_ADDR_SEL_CU /main_tb/DUV/NEXT_ADDR_SEL_CU_jumpOrBranch
add wave -noupdate -expand -group NEXT_ADDR_SEL_CU /main_tb/DUV/NEXT_ADDR_SEL_CU_jalrOut
add wave -noupdate -group FWU /main_tb/DUV/FWU_fwdWriteData
add wave -noupdate -group FWU /main_tb/DUV/FWU_fwdA
add wave -noupdate -group FWU /main_tb/DUV/FWU_fwdB
add wave -noupdate -divider IF
add wave -noupdate -radix unsigned /main_tb/DUV/NEXT_PC_MUX_out
add wave -noupdate -radix unsigned /main_tb/DUV/PC_q
add wave -noupdate -radix unsigned /main_tb/DUV/NEXT_PC_ADDER_out
add wave -noupdate -divider ID
add wave -noupdate -radix unsigned /main_tb/DUV/IF_ID_pc
add wave -noupdate -radix unsigned /main_tb/DUV/IF_ID_nextPc
add wave -noupdate -radix hexadecimal /main_tb/DUV/ifId_FLUSH_MUX_out
add wave -noupdate /main_tb/DUV/ifId_FLUSH_FF_q
add wave -noupdate -radix decimal -childformat {{{/main_tb/DUV/RF/regs[0]} -radix decimal} {{/main_tb/DUV/RF/regs[1]} -radix decimal} {{/main_tb/DUV/RF/regs[2]} -radix decimal} {{/main_tb/DUV/RF/regs[3]} -radix decimal} {{/main_tb/DUV/RF/regs[4]} -radix decimal} {{/main_tb/DUV/RF/regs[5]} -radix decimal} {{/main_tb/DUV/RF/regs[6]} -radix decimal} {{/main_tb/DUV/RF/regs[7]} -radix decimal} {{/main_tb/DUV/RF/regs[8]} -radix decimal} {{/main_tb/DUV/RF/regs[9]} -radix decimal} {{/main_tb/DUV/RF/regs[10]} -radix decimal} {{/main_tb/DUV/RF/regs[11]} -radix decimal} {{/main_tb/DUV/RF/regs[12]} -radix decimal} {{/main_tb/DUV/RF/regs[13]} -radix decimal} {{/main_tb/DUV/RF/regs[14]} -radix decimal} {{/main_tb/DUV/RF/regs[15]} -radix decimal} {{/main_tb/DUV/RF/regs[16]} -radix decimal} {{/main_tb/DUV/RF/regs[17]} -radix decimal} {{/main_tb/DUV/RF/regs[18]} -radix decimal} {{/main_tb/DUV/RF/regs[19]} -radix decimal} {{/main_tb/DUV/RF/regs[20]} -radix decimal} {{/main_tb/DUV/RF/regs[21]} -radix decimal} {{/main_tb/DUV/RF/regs[22]} -radix decimal} {{/main_tb/DUV/RF/regs[23]} -radix decimal} {{/main_tb/DUV/RF/regs[24]} -radix decimal} {{/main_tb/DUV/RF/regs[25]} -radix decimal} {{/main_tb/DUV/RF/regs[26]} -radix decimal} {{/main_tb/DUV/RF/regs[27]} -radix decimal} {{/main_tb/DUV/RF/regs[28]} -radix decimal} {{/main_tb/DUV/RF/regs[29]} -radix decimal} {{/main_tb/DUV/RF/regs[30]} -radix decimal} {{/main_tb/DUV/RF/regs[31]} -radix decimal}} -subitemconfig {{/main_tb/DUV/RF/regs[0]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[1]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[2]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[3]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[4]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[5]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[6]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[7]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[8]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[9]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[10]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[11]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[12]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[13]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[14]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[15]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[16]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[17]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[18]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[19]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[20]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[21]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[22]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[23]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[24]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[25]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[26]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[27]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[28]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[29]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[30]} {-height 17 -radix decimal} {/main_tb/DUV/RF/regs[31]} {-height 17 -radix decimal}} /main_tb/DUV/RF/regs
add wave -noupdate -radix decimal /main_tb/DUV/RF_dataOut0
add wave -noupdate -radix decimal /main_tb/DUV/RF_dataOut1
add wave -noupdate -radix decimal /main_tb/DUV/IMM_GEN_immediate
add wave -noupdate /main_tb/DUV/ALU_DECODER_ctl
add wave -noupdate -radix binary /main_tb/DUV/idEx_FLUSH_MUX_out
add wave -noupdate -divider EX
add wave -noupdate /main_tb/DUV/ID_EX_controls
add wave -noupdate /main_tb/DUV/ID_EX_aluCtl
add wave -noupdate -radix decimal /main_tb/DUV/ID_EX_dataOut0
add wave -noupdate -radix decimal /main_tb/DUV/ID_EX_dataOut1
add wave -noupdate -radix decimal /main_tb/DUV/ID_EX_immediate
add wave -noupdate -radix unsigned /main_tb/DUV/ID_EX_pc
add wave -noupdate -radix unsigned /main_tb/DUV/ID_EX_nextPc
add wave -noupdate /main_tb/DUV/ID_EX_rd
add wave -noupdate /main_tb/DUV/ID_EX_rs1
add wave -noupdate /main_tb/DUV/ID_EX_rs2
add wave -noupdate /main_tb/DUV/exDmem_FLUSH_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/RS1_ALU_FWD_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/RS2_ALU_FWD_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/RS1_PC_ALU_SRC_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/RS2_IMM_ALU_SRC_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/ALU_out
add wave -noupdate -radix decimal /main_tb/DUV/BR_JAL_ADDER_out
add wave -noupdate -divider DMEM
add wave -noupdate /main_tb/DUV/EX_DMEM_controls
add wave -noupdate -radix hexadecimal /main_tb/DUV/EX_DMEM_memDataIn
add wave -noupdate -radix decimal /main_tb/DUV/EX_DMEM_WB_aluOut
add wave -noupdate -radix unsigned /main_tb/DUV/EX_DMEM_jumpAddr
add wave -noupdate -radix unsigned /main_tb/DUV/EX_DMEM_nextPc
add wave -noupdate -radix decimal /main_tb/DUV/EX_DMEM_rd
add wave -noupdate -radix decimal /main_tb/DUV/EX_DMEM_rs2
add wave -noupdate -radix decimal /main_tb/DUV/BRJAL_JALR_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/DMEM_FWD_MUX_out
add wave -noupdate -divider WB
add wave -noupdate /main_tb/DUV/DMEM_WB_controls
add wave -noupdate -radix decimal /main_tb/DUV/DMEM_WB_aluOut
add wave -noupdate -radix unsigned /main_tb/DUV/DMEM_WB_nextPc
add wave -noupdate /main_tb/DUV/DMEM_WB_rd
add wave -noupdate -radix decimal /main_tb/DUV/DMEM_ALU_WB_MUX_out
add wave -noupdate -radix decimal /main_tb/DUV/JUMP_WB_MUX_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {96 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 279
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {313 ns}
