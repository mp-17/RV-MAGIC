`include "../../common/src/rv32i_defs.sv"

// this cu is only combinational since the memory part is supplied by the pipeline registers
// it simply takes all the codes from the current instruction and computes the corresponding output control signals
module cu
(
    input [`INST_WIDTH-1:0] instruction,  // input instruction to be decoded
    output [`IMMEDIATE_SELECTION_WIDTH-1:0] imm_type, // to control the immediate generation unit 
    output D_MEM_write, D_MEM_read, D_MEM_mode, // control signal for the DMEM. "mode" is for bit width selection. #Old: MemWrite, MemRead, -
    output RF_write, // write control signal for the RF. #Old: RegWrite
    output RS2_IMM_ALU_SRC_MUX_sel, // sel for the mux on the second input (b) of the ALU. Select either IMM or $(Rs2). #Old: ALUSrc
    output DMEM_ALU_WB_MUX_sel, // sel for the mux in WB stage. Let pass either DMEM_dataOut or ALU_out. #Old: MemtoReg
    output branch, jump, jalr // asserted if the instruction is respectivly a branch, a JAL, a JALR. #OLD: Branch
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
