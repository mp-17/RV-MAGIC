/*  Forwarding unit to avoid stalls in the pipeline when the needed input
    is already present in the following stages.
    If the same register is present in EX/MEM and MEM/WB stages, the former
    takes precedence.
    The outputs should be connected to the control signals of two muxes
    choosing the ALU inputs.
*/

`include "../../common/src/rv32i_defs.sv"

module fwu (
    input [`RF_ADDR_WIDTH-1:0] idexRs1, idexRs2, exmemRd, memwbRd,
    input exmemRegWrite, memwbRegWrite,
    output logic [1:0] fwdA, fwdB
);

    always_comb begin
        // ALU input A
        if (exmemRegWrite && (exmemRd != 0) && (exmemRd == idexRs1)) 
            fwdA = 2'b10; // forward from previous ALU result
        else if (memwbRegWrite && (memwbRd != 0) && (memwbRd == idexRs1)) 
            fwdA = 2'b01; // forward from memory/earlier ALU result
        else
            fwdA = 2'b00; // don't forward

        // ALU input B
        if (exmemRegWrite && (exmemRd != 0) && (exmemRd == idexRs2)) 
            fwdB = 2'b10; // forward from previous ALU result
        else if (memwbRegWrite && (memwbRd != 0) && (memwbRd == idexRs2)) 
            fwdB = 2'b01; // forward from memory/earlier ALU result
        else
            fwdB = 2'b00; // don't forward
    end
endmodule