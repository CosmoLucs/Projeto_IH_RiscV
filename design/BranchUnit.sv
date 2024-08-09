`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm,
    input logic Branch,
    input logic [31:0] AluResult,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel,
    input logic [6:0] opcode
);

  logic Branch_Sel;
  logic [31:0] PC_Full;
  
  /*
    checa se o opcode é o de halt, 
      se for determina que um branch ocorrerá em Branch_Sel
      e atribui o mesmo valor do pc após o branch com PC_Imm
  */

  logic halt;

  assign PC_Full = {23'b0, Cur_PC};
  assign halt = opcode == 7'b1111111;
  
  assign PC_Four = PC_Full + 32'b100;
  assign PC_Imm = halt ? PC_Full : PC_Full + Imm;
  assign Branch_Sel = halt || (Branch && AluResult[0]);  // 0:Branch is taken; 1:Branch is not taken

  assign BrPC = (Branch_Sel) ? PC_Imm : 32'b0;  // Branch -> PC+Imm   // Otherwise, BrPC value is not important
  assign PcSel = Branch_Sel;  // 1:branch is taken; 0:branch is not taken(choose pc+4)

endmodule
