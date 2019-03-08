`include "../../common/src/rv32i_defs.sv"

// this cu is only combinational since the memory part is supplied by the pipeline registers
// it simply takes all the codes from the current instruction and computes the corresponding output control signals
module cu
(
    input [`INST_WIDTH-1:0] instruction,
    output [`IMMEDIATE_SELECTION_WIDTH-1:0] imm_type,
    output if_enable, id_reg, ex_reg, mem_reg, wb_reg,
    output pc_load,
    output inst_mem_enable,
    output data_mem_write, data_mem_read,
    output branch, jump,
    output reg_file_write,
    output mem2reg,
    output MUX_selection_for_reg_dest // ???????????????
);


    import rv32i;

    always_comb begin
        case(instruction[0+:7])
            RV32I_LUI_OPCODE :
            begin
            end

            begin
            end

            default :

        endcase
    end
endmodule
