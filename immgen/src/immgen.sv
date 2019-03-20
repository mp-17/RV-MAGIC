`include "../../common/src/rv32i_defs.sv"

module immgen
(
    input [`INST_WIDTH-1:0] instruction,
    input [`IMMEDIATE_SELECTION_WIDTH-1:0] imm_type, // we need the CU to tell us the type of instruction
    output logic [`WORD_WIDTH-1:0] immediate
);

    always_comb begin
        case(imm_type)
            `I_TYPE :
            begin
                immediate[0] = instruction[20];
                immediate[1+:4] = instruction[21+:4];
                immediate[5+:6] = instruction[25+:6];
                for (int i = 0; i < 22; i++)
                    immediate[11+i] = instruction[31];
            end
            `S_TYPE :
            begin
                immediate[0] = instruction[7];
                immediate[1+:4] = instruction[8+:4];
                immediate[5+:6] = instruction[25+:6];
                for (int i = 0; i < 22; i++)
                    immediate[11+i] = instruction[31];
            end
            `B_TYPE :
            begin
                immediate[0+:4] = instruction[8+:4];
                immediate[4+:6] = instruction[25+:6];
                immediate[10] = instruction[7];
                for (int i = 0; i < 21; i++)
                    immediate[11+i] = instruction[31];
            end
            `U_TYPE :
            begin
                for (int i = 0; i < 12; i++)
                immediate[i] = 0;
                immediate[12+:8] = instruction[12+:8];
                immediate[20+:11] = instruction[20+:11];
                immediate[31] = instruction[31];
            end
            `J_TYPE :
            begin
                immediate[0+:4] = instruction[21+:4];
                immediate[4+:6] = instruction[25+:6];
                immediate[10] = instruction[20];
                immediate[11+:8] = instruction[12+:8];
                for (int i = 0; i < 13; i++)
                    immediate[19+i] = instruction[31];
            end

            default: immediate = 0;
        endcase
    end
endmodule
